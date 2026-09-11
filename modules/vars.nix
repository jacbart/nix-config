{ lib, ... }:
{
  _module.args = {
    vars = rec {
      domain = "meep.sh";
      email = "jacbart@gmail.com";
      timezone = "America/Phoenix";
      acmeDnsProvider = "cloudflare";
      lanSubnet = "10.120.0.0/24";
      lanGateway = "10.120.0.1";
      lanDomain = "lan.meep.sh";

      # Public IPv4 of the oak edge (DigitalOcean droplet, FRA). Only changes
      # when the droplet is rebuilt. PTR comes from the droplet name
      # (mail.meep.sh).
      publicIps.oak = "46.101.182.66";

      # Tailscale IPv4s by host. Postfix relay trust/targets, oak's nginx
      # upstreams and the /etc/hosts service catalog derive from this map.
      # Fleet DNS records are generated from it at sync time (cloudflare-dns.nix);
      # keep values in sync with `tailscale status` when devices re-register.
      tailscaleIps = {
        maple = "100.116.178.48";
        oak = "100.97.69.102";
        ash = "100.69.126.51";
        boojum = "100.118.9.78";
        cork = "100.113.192.12";
        sycamore = "100.88.231.43";
        unicron = "100.78.207.83";
        acorn = "100.107.253.35";
      };

      # NixOS hosts opted in to the hardened fail2ban profile: explicit sshd /
      # recidive jails plus a daily-fed scanner blocklist
      # (Shodan/Censys C2, Spamhaus DROP/EDROP, FireHOL L1–L3) dropped at the
      # firewall via ipset. Add a host's networking.hostName here to opt in.
      # The host must also import profileFail2ban (see
      # modules/nixos/service-profiles.nix); sshguard is automatically disabled
      # on these hosts (see modules/nixos/services/openssh.nix).
      hardenedHosts = [
        "oak"
        "maple"
        "mesquite"
      ];

      # Shared across nixos / home-manager / darwin nix.settings
      nixAllowedUris = [
        "github:"
        "git+https://github.com/"
        "git+https://git.vdx.hu/"
        "git+ssh://github.com/"
      ];

      nixSubstitutersPublic = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      nixTrustedPublicKeysPublic = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      nixSubstitutersNixOS = [
        "https://nix-cache.${domain}"
      ]
      ++ nixSubstitutersPublic;

      nixTrustedPublicKeysNixOS = [
        "nix-cache.${domain}-1:q58+Lt6h68AmBke4wpJatSrpe1cZvDzVNDTp8qurEbs="
      ]
      ++ nixTrustedPublicKeysPublic;

      # ── Distributed build registry ──────────────────────────────────────────
      # Nix has no runtime builder auto-discovery (NixOS/nix#523: "let
      # provisioners update /etc/nix/machines"). For a fixed flake host set
      # this shared list IS the "determine what's available" — every host gets
      # the full list (minus itself), and Nix's scheduler routes jobs optimally
      # via speedFactor / maxJobs / supportedFeatures.
      #
      # speedFactor: relative integer, higher = faster.  Tuned to the fleet.
      # sshKey: absolute path to the shared remotebuild private key (sops).
      # publicHostKey: base64 ed25519 host key for MITM-safe SSH (null = use
      #   known_hosts; fill in via `ssh-keyscan -t ed25519 <host>`).
      remotebuildKey = "/var/secrets/remotebuild_id";

      # FQDNs so builder SSH resolves via public DNS (bare hostnames don't
      # resolve on strict-DoT hosts; MagicDNS is not relied upon).
      builders = [
        {
          hostName = "cork.${domain}";
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          speedFactor = 10;
          maxJobs = 8;
          supportedFeatures = [
            "kvm"
            "big-parallel"
            "nixos-test"
            "benchmark"
          ];
          publicHostKey = null;
        }
        {
          hostName = "boojum.${domain}";
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          speedFactor = 6;
          maxJobs = 8;
          supportedFeatures = [
            "kvm"
            "big-parallel"
            "nixos-test"
            "benchmark"
          ];
          publicHostKey = null;
        }
        {
          hostName = "maple.${domain}";
          systems = [ "aarch64-linux" ];
          speedFactor = 2;
          maxJobs = 2;
          supportedFeatures = [ "big-parallel" ];
          publicHostKey = null;
        }
        {
          hostName = "ash.${domain}";
          systems = [ "aarch64-linux" ];
          speedFactor = 1;
          maxJobs = 1;
          supportedFeatures = [ ];
          publicHostKey = null;
        }
      ];

      # SSH host keys for known_hosts (MITM protection for the build channel).
      # Keys must be keyed by FQDN (what ssh actually connects to). Verify with
      # `ssh-keyscan -t ed25519 <fqdn>` after re-imaging a builder.
      builderHostKeys = {
        "boojum.${domain}" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4MTXIg+HPG7g8ZKCReM2nRMcC3+m3MPStHL5sw9E7H";
        "ash.${domain}" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQCfoMseiQ9Ddr9boq7bnGvMdK6egjvshXptsWXgNsu";
        "maple.${domain}" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4sTgZqEhhNkle8EwV+vWjOL11WjK+QyllSRTpPw8wk";
        "cork.${domain}" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5Mu5GWUBvLLK/y/Zr+rLmr44QlLhAQgvcKIHoLgvha";
      };

      # Host keys for non-builder hosts reached over SSH by flake inputs
      # (supply-chain MITM protection). The `got` input fetches
      # git+ssh://git@got.bbl.systems; pin its key so a DNS/BGP poisoning
      # cannot substitute a rogue server during evaluation.
      extraKnownHosts = {
        "got.bbl.systems" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOUi4f/tscM+MdtNIwB3RbxzaQ8Rq1J+a5hY0CUtC5b";
      };

      # ── Declarative Cloudflare DNS (octodns; see nixos/services/cloudflare-dns.nix) ──
      # `records` is the single source of truth for the zone. Fleet hostname
      # A records are NOT listed here — they are generated at sync time from
      # `tailscale status --json` on oak using the `fleetHosts` allowlist.
      # All A records are DNS-only (grey): SMTP and Tailscale traffic must
      # never be proxied.
      # One grey A record pointing at a Tailscale IP (helper for dns.records).
      tsRecords = ip: [
        {
          type = "A";
          ttl = 300;
          values = [ ip ];
        }
      ];

      dns = {
        zone = domain;
        fleetHosts = [
          "oak"
          "maple"
          "ash"
          "boojum"
          "cork"
          "sycamore"
          "unicron"
          "acorn"
        ];
        # Abort a sync when fewer allowlisted peers than this are visible to
        # tailscaled (guards against mass-deleting fleet records on a flaky
        # or unauthenticated API call).
        fleetMinPeers = 4;
        records = {
          # Apex: edge (anubis/nginx) + mail routing + SPF
          "" = [
            {
              type = "A";
              ttl = 300;
              values = [ publicIps.oak ];
            }
            {
              type = "MX";
              ttl = 300;
              values = [
                {
                  exchange = "mail.${domain}.";
                  preference = 10;
                }
              ];
            }
            {
              type = "TXT";
              ttl = 300;
              values = [ "v=spf1 mx ~all" ];
            }
          ];
          www = [
            {
              type = "A";
              ttl = 300;
              values = [ publicIps.oak ];
            }
          ];
          # Public edge vhosts terminated on oak
          matrix = [
            {
              type = "A";
              ttl = 300;
              values = [ publicIps.oak ];
            }
          ];
          tun = [
            {
              type = "A";
              ttl = 300;
              values = [ publicIps.oak ];
            }
          ];
          # MX target (postfix edge on oak; PTR = droplet name)
          mail = [
            {
              type = "A";
              ttl = 300;
              values = [ publicIps.oak ];
            }
          ];
          # maple-served names reachable over Tailscale
          nix-cache = tsRecords tailscaleIps.maple;
          auth = tsRecords tailscaleIps.maple;
          books = tsRecords tailscaleIps.maple;
          photos = tsRecords tailscaleIps.maple;
          files = tsRecords tailscaleIps.maple;
          wiki = tsRecords tailscaleIps.maple;
          got = tsRecords tailscaleIps.maple;
          s3 = tsRecords tailscaleIps.maple;
          fs = tsRecords tailscaleIps.maple;
          rss = tsRecords tailscaleIps.maple;
          # Heavy LAN traffic (calibre ingest) stays on maple's LAN
          calibre = [
            {
              type = "A";
              ttl = 300;
              values = [ "192.168.0.44" ];
            }
          ];
          _dmarc = [
            {
              type = "TXT";
              ttl = 300;
              # octodns TXT values escape ";" as "\;" (the provider
              # un-escapes before sending to the Cloudflare API).
              values = [ "v=DMARC1\\; p=none\\; rua=mailto:postmaster@${domain}\\; pct=100" ];
            }
          ];
          # DKIM public key for rspamd's outbound signing on maple
          # (selector "mail"; generated once by maple's mail-dkim-keygen
          # service into /var/lib/mail/dkim/meep.sh.mail.txt).
          "mail._domainkey" = [
            {
              type = "TXT";
              ttl = 300;
              # octodns TXT values escape ";" as "\;" (the provider
              # un-escapes before sending to the Cloudflare API).
              values = [
                "v=DKIM1\\; k=rsa\\; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtQpno/Bisd5fgt5md5efP9YqknZkQUh4qqtntVfRWh76jTX/vRW1YI3FmtIkc9IwLJUfm4pQnZ9ljK3fpw/mqjlxKxEHvu9WKyKupw7k89mFXmSIdALGTUrOymLHxWh6VNFDwi++sNMbjQS6hW4KDPBiiR3n/blg6Y0nN/qXGyBmb9ccY84JrRwmjnWRJBB8ogF/Q4rgU09mjLe4ahnYp7TQPdMpwdQnsHmJyA+mDYT8dfBqyJeVO0eIfdD1LapfoASoI5tbGRO/kC0p4ue7GQREp40HQanNlPF2To6LvbZK8RQL4nX5j0fXIi8TUOwni4EE8OoeJmRHfuWv+R2E4QIDAQAB"
              ];
            }
          ];
        };
      };

      serviceCatalog = import ./service-catalog.nix {
        inherit
          domain
          tailscaleIps
          ;
      };
    };
    stateVersion = lib.mkDefault "26.05";
  };
}
