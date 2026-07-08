{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  # Hosts opted in via vars.hardenedHosts get explicit jails + a daily-fed
  # scanner blocklist (Shodan/Censys C2, Spamhaus DROP/EDROP, FireHOL L1–L3).
  # Other fail2ban hosts get the baseline below (default sshd jail).
  hardened = builtins.elem config.networking.hostName vars.hardenedHosts;
  ipsetName = "f2b-scanners";

  fetchScript = pkgs.writeShellScript "scanner-blocklist-fetch" ''
    set -eu
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    combined="$tmpdir/combined.txt"
    : > "$combined"

    fetch() {
      url="$1"; parser="$2"
      raw="$tmpdir/$(basename "$url")"
      if ! curl --silent --show-error --fail --max-time 60 --connect-timeout 15 \
           -H 'User-Agent: nixos-blocklist-fetch/1.0' \
           "$url" > "$raw"; then
        echo "WARN: failed to fetch $url — skipping" >&2
        return 0
      fi
      case "$parser" in
        firehol)  awk '/^[0-9]/ {print $1}'           "$raw" > "$raw.parsed" ;;
        spamhaus) awk -F';'     '/^[0-9]/ {print $1}' "$raw" > "$raw.parsed" ;;
      esac
      count=$(wc -l < "$raw.parsed" 2>/dev/null || echo 0)
      if [ "$count" -gt 200000 ]; then
        echo "ERROR: $url returned $count entries (>200000) — likely poisoned, aborting" >&2
        return 1
      fi
      cat "$raw.parsed" >> "$combined"
    }

    # Aggregated reputable blocklists (L1 conservative → L3 aggressive)
    fetch "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset" firehol
    fetch "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset" firehol
    fetch "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset" firehol

    # Hijacked / persistent malicious networks (source of truth)
    fetch "https://www.spamhaus.org/drop/drop.txt"  spamhaus
    fetch "https://www.spamhaus.org/drop/edrop.txt" spamhaus

    # C2 frameworks tracked via Shodan + Censys data
    fetch "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/c2_tracker.ipset" firehol

    # ── Dedup + validate ──
    sort -u "$combined" \
      | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?$/' \
      > "$combined.dedup"

    total=$(wc -l < "$combined.dedup")
    if [ "$total" -eq 0 ]; then
      echo "WARN: all feeds empty — keeping existing ${ipsetName} set" >&2
      exit 0
    fi

    # ── Atomic swap via a tmp set ──
    ${pkgs.ipset}/bin/ipset create "${ipsetName}" hash:net family inet hashsize 4096 maxelem 1048576 -exist
    restore="$tmpdir/restore.txt"
    {
      echo "create ${ipsetName}-tmp hash:net family inet hashsize 4096 maxelem 1048576 -exist"
      while IFS= read -r cidr; do
        echo "add ${ipsetName}-tmp $cidr -exist"
      done < "$combined.dedup"
      echo "swap ${ipsetName}-tmp ${ipsetName}"
      echo "destroy ${ipsetName}-tmp"
    } > "$restore"
    ${pkgs.ipset}/bin/ipset restore -exist -f "$restore"
    echo "Loaded $total unique entries into ${ipsetName}"
  '';
in
{
  # Caddy JSON access-log filter — matches /var/log/caddy/access-*.log written
  # by modules/nixos/services/caddy.nix. Only materialised on hardened hosts
  # running Caddy.
  environment.etc = lib.optionalAttrs (hardened && config.services.caddy.enable) {
    "fail2ban/filter.d/caddy-status.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<HOST>",.*?"status":(?:401|403|500),.*$
      ignoreregex =
      datepattern = LongEpoch
    '';
  };

  services.fail2ban = {
    enable = true;
    extraPackages = [ pkgs.ipset ];

    # ── Baseline (all fail2ban hosts) ──
    maxretry = 3;
    ignoreIP = [ "100.100.100.100/10" ];
    bantime = "24h";
    bantime-increment = {
      enable = true;
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h";
      overalljails = true;
    };
    banaction = "iptables-ipset-proto6-allports";

    jails = lib.mkMerge (
      [
        {
          # Explicit sshd jail — predictable settings on all fail2ban hosts.
          sshd.settings = {
            enabled = true;
            port = "ssh";
            maxretry = 3;
            findtime = "10m";
            bantime = "24h";
          };
        }
      ]
      ++ lib.optional hardened {
        # Long-ban repeat offenders across all jails.
        recidive.settings = {
          enabled = true;
          maxretry = 3;
          findtime = "1d";
          bantime = "1w";
        };
      }
      ++ lib.optional (hardened && config.services.caddy.enable) {
        # Ban IPs returning 401/403/500 from Caddy — filter defined above.
        caddy-status.settings = {
          enabled = true;
          port = "http,https";
          filter = "caddy-status";
          logpath = "/var/log/caddy/*.access.log";
          maxretry = 5;
          findtime = "10m";
          bantime = "1h";
        };
      }
    );
  };

  # ── Scanner blocklist (hardened hosts only) ──────────────────────────────
  # The ipset is created empty at firewall bring-up so the DROP rule can
  # attach immediately; scanner-blocklist-fetch.service fills it shortly
  # after boot and daily thereafter. Uses the same iptables + ipset stack
  # as fail2ban's banaction above.
  networking.firewall = lib.optionalAttrs hardened {
    extraCommands = ''
      ${pkgs.ipset}/bin/ipset create ${ipsetName} hash:net family inet hashsize 4096 maxelem 1048576 -exist
      ${pkgs.iptables}/bin/iptables -I INPUT -m set --match-set ${ipsetName} src -j DROP
    '';
    extraStopCommands = ''
      ${pkgs.iptables}/bin/iptables -D INPUT -m set --match-set ${ipsetName} src -j DROP 2>/dev/null || true
    '';
  };

  systemd.services.scanner-blocklist-fetch = lib.optionalAttrs hardened {
    description = "Fetch and refresh the ${ipsetName} ipset from public blocklists";
    after = [
      "network-online.target"
      "firewall.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = fetchScript;
    };
    path = [
      pkgs.curl
      pkgs.ipset
      pkgs.gawk
      pkgs.coreutils
    ];
  };

  systemd.timers.scanner-blocklist-fetch = lib.optionalAttrs hardened {
    description = "Daily refresh of the ${ipsetName} ipset";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "24h";
      Persistent = true;
    };
  };
}
