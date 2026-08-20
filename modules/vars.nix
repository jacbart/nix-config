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

      # NixOS hosts opted in to the hardened fail2ban profile: explicit sshd /
      # caddy-status / recidive jails plus a daily-fed scanner blocklist
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
        "https://nix-citizen.cachix.org"
        "https://cache.nixos.org"
      ];

      nixTrustedPublicKeysPublic = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
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

      builders = [
        {
          hostName = "cork";
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
          hostName = "boojum";
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
          hostName = "maple";
          systems = [ "aarch64-linux" ];
          speedFactor = 2;
          maxJobs = 2;
          supportedFeatures = [ "big-parallel" ];
          publicHostKey = null;
        }
        {
          hostName = "ash";
          systems = [ "aarch64-linux" ];
          speedFactor = 1;
          maxJobs = 1;
          supportedFeatures = [ ];
          publicHostKey = null;
        }
      ];

      # SSH host keys for known_hosts (MITM protection for the build channel).
      # Run `ssh-keyscan -t ed25519 <host>` and paste the key here.
      builderHostKeys = {
        boojum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4MTXIg+HPG7g8ZKCReM2nRMcC3+m3MPStHL5sw9E7H";
        ash = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQCfoMseiQ9Ddr9boq7bnGvMdK6egjvshXptsWXgNsu";
        maple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4sTgZqEhhNkle8EwV+vWjOL11WjK+QyllSRTpPw8wk";
        cork = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQCfoMseiQ9Ddr9boq7bnGvMdK6egjvshXptsWXgNsu";
        # colima = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvJR2xPpXLBfD+QmKhHz2r6UK+7kASNcYOk6q7H7sl3";
      };

      serviceCatalog = import ./service-catalog.nix { inherit domain; };
    };
    stateVersion = lib.mkDefault "25.11";
  };
}
