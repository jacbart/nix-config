# Declarative Cloudflare DNS for vars.dns.zone via octodns.
#
# Sources of truth (merged):
#   1. vars.dns.records  — static service/MX/TXT records (in the flake)
#   2. fleet A records   — generated at sync time from `tailscale status
#                          --json` on this host, filtered to
#                          vars.dns.fleetHosts (so they can never drift)
# Target: the Cloudflare zone (token from the existing cloudflare_api_key
# sops secret; lego and octodns share CLOUDFLARE_DNS_API_TOKEN).
#
# Safety:
#   - the fleet generator aborts unless at least vars.dns.fleetMinPeers
#     allowlisted peers are visible (a flaky/unauthenticated tailscale call
#     can never mass-delete fleet records)
#   - an IgnoreNameFilter keeps octodns away from _acme-challenge names so
#     a sync can never race or prune lego's in-flight DNS-01 TXT records
#   - there is deliberately NO timer: every apply is explicit
#
# Usage (from the repo root, after this config is live on oak):
#   task dns:plan    dry-run — shows the exact changes octodns would make
#   task dns:apply   octodns-sync --doit
#   task dns:dump    dump the live zone as octodns YAML (adoption reference)
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  inherit (vars.dns)
    zone
    records
    fleetHosts
    fleetMinPeers
    ;

  # octodns CLI + the cloudflare provider module in one python env. The
  # provider is packaged against octodns's own overridden python (see
  # pkgs/by-name/oc/octodns in nixpkgs), so it must come from
  # octodns-providers.cloudflare — it is not a member of `ps` in
  # withProviders' lambda on this nixpkgs.
  octodns = pkgs.octodns.withProviders (ps: [ pkgs.octodns-providers.cloudflare ]);

  formats = pkgs.formats.yaml { };

  # One octodns record entry. A/AAAA records carry an explicit grey-cloud
  # flag so a sync can never accidentally toggle the Cloudflare proxy on
  # (SMTP/Tailscale traffic must stay DNS-only).
  mkRecord =
    r:
    (lib.optionalAttrs (r.type == "A" || r.type == "AAAA") {
      octodns.cloudflare.proxied = false;
    })
    // {
      inherit (r) type ttl;
      values = r.values;
    };

  # octodns zone YAML: a name maps to a single record dict, or a list when
  # several record types share the name (e.g. apex A + MX + TXT).
  zoneYaml = lib.mapAttrs (
    _name: rs:
    let
      rendered = map mkRecord rs;
    in
    if lib.length rendered == 1 then lib.head rendered else rendered
  ) records;

  staticZoneDir = pkgs.runCommand "octodns-static-${zone}" { } ''
    mkdir -p $out
    ln -s ${formats.generate "${zone}.yaml" zoneYaml} $out/${zone}.yaml
  '';

  fleetDir = "/run/octodns-cloudflare/fleet";

  configFile = formats.generate "octodns-config.yaml" {
    providers = {
      static = {
        class = "octodns.provider.yaml.YamlProvider";
        directory = toString staticZoneDir;
      };
      fleet = {
        class = "octodns.provider.yaml.YamlProvider";
        directory = fleetDir;
      };
      cloudflare = {
        class = "octodns_cloudflare.CloudflareProvider";
        # Same token lego uses for ACME DNS-01 (CLOUDFLARE_DNS_API_TOKEN in
        # the cloudflare_api_key sops env file).
        token = "env/CLOUDFLARE_DNS_API_TOKEN";
        # No page rules / URLFWD records are managed here. Disabling this
        # skips the /pagerules API call during populate, which would otherwise
        # 403 because the token is scoped to Zone.DNS only (not Firewall
        # Services).
        pagerules = false;
      };
    };
    processors = {
      # lego creates/deletes _acme-challenge TXT records during renewals —
      # never manage (or prune) them from here. Patterns wrapped in /…/ are
      # regexes; octodns 1.15 renamed IgnoreNameFilter → NameRejectlistFilter.
      ignore-acme-challenge = {
        class = "octodns.processor.filter.NameRejectlistFilter";
        rejectlist = [ "/_acme-challenge/" ];
      };
    };
    zones."${zone}." = {
      sources = [
        "static"
        "fleet"
      ];
      targets = [ "cloudflare" ];
      processors = [ "ignore-acme-challenge" ];
    };
  };

  # Renders the fleet A records from the live tailscale state. Emits YAML by
  # hand: values are hostnames and IPs only, so no quoting is needed.
  fleetGen = pkgs.writeShellScript "octodns-fleet-gen" ''
    set -euo pipefail
    mkdir -p "${fleetDir}"
    allow=$(printf '%s\n' ${
      lib.concatStringsSep " " (map (h: "'${h}'") fleetHosts)
    } | ${pkgs.jq}/bin/jq -R . | ${pkgs.jq}/bin/jq -s .)
    peers=$(${lib.getExe pkgs.tailscale} status --json | ${pkgs.jq}/bin/jq -r --argjson allow "$allow" '
      # .Peer is an object keyed by nodekey on current tailscale; tolerate an
      # array too. Self is always present.
      ([.Self] + [(.Peer // {})[]])
      | .[]
      | select((.HostName // "") | IN($allow[]))
      | select((.TailscaleIPs // []) | length > 0)
      | "\(.HostName) \(.TailscaleIPs[0])"
    ')
    count=$(printf '%s\n' "$peers" | grep -c . || true)
    if [ "$count" -lt ${toString fleetMinPeers} ]; then
      echo "octodns fleet generation aborted: only $count/${toString (lib.length fleetHosts)} allowlisted peers visible (floor ${toString fleetMinPeers})." >&2
      exit 1
    fi
    : > "${fleetDir}/${zone}.yaml"
    # Top-level record names must be alphabetized too (octodns 1.15
    # enforce_order applies to the whole file, not just record keys).
    printf '%s\n' "$peers" | sort | while read -r name ip; do
      printf '%s:\n  octodns:\n    cloudflare:\n      proxied: false\n  ttl: 300\n  type: A\n  values:\n    - %s\n' \
        "$name" "$ip" >> "${fleetDir}/${zone}.yaml"
    done
    echo "fleet records generated: $count" >&2
  '';

  mkSyncService = name: doit: {
    description = "octodns ${name} for ${zone} (Cloudflare${lib.optionalString doit ", applies changes"})";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RuntimeDirectory = "octodns-cloudflare";
      EnvironmentFile = config.sops.secrets."cloudflare_api_key".path;
      ExecStartPre = [ "${fleetGen}" ];
      # --force bypasses octodns's 30%-change safety threshold so a first
      # adoption (or a fleet-wide tailscale IP drift) can always be planned
      # and reviewed. It does NOT auto-apply: --doit is only appended for
      # the apply unit, and there is deliberately no timer.
      ExecStart = "${octodns}/bin/octodns-sync --config-file ${configFile} --force${lib.optionalString doit " --doit"}";
    };
  };
in
{
  systemd.services = {
    octodns-cloudflare-plan = mkSyncService "plan" false;
    octodns-cloudflare-apply = mkSyncService "apply" true;

    octodns-cloudflare-dump = {
      description = "Dump the live ${zone} Cloudflare zone as octodns YAML";
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "octodns-cloudflare";
        StateDirectory = "octodns-cloudflare";
        EnvironmentFile = config.sops.secrets."cloudflare_api_key".path;
        ExecStartPre = [ "${fleetGen}" ];
        ExecStart = "${octodns}/bin/octodns-dump --config-file=${configFile} --output-dir=/var/lib/octodns-cloudflare/dump ${zone}. cloudflare";
      };
    };
  };
}
