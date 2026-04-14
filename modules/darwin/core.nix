# Darwin Core Module - Dendritic Pattern
# Exports core Darwin configuration as flake.modules.darwin.core

{ ... }:
{
  flake.modules.darwin.core =
    {
      inputs,
      lib,
      pkgs,
      vars,
      overlays,
      username,
      ...
    }:
    {
      users.users = lib.mkDefault { };

      environment.systemPackages = with pkgs; [
        unstable.nixos-rebuild-ng
        jq
      ];

      programs.zsh.enable = true;

      # Nix daemon (root) runs SSH for remote builders; it does not use ~/.ssh/known_hosts.
      programs.ssh.knownHosts.maple = {
        hostNames = [
          "maple"
          "maple.meep.sh"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4sTgZqEhhNkle8EwV+vWjOL11WjK+QyllSRTpPw8wk";
      };

      nixpkgs = {
        overlays = lib.attrValues overlays;
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

      nix = {
        package = pkgs.lixPackageSets.latest.lix;
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        gc = {
          automatic = true;
          options = "--delete-older-than 10d";
        };
        optimise.automatic = true;

        # Deploying NixOS (e.g. aarch64-linux maple) from this Mac requires
        # delegating linux drvs (e.g. system.build.nixos-rebuild) to a linux builder.
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "maple";
            protocol = "ssh";
            sshUser = "ratatoskr";
            # Root nix-daemon cannot resolve ~ to your login user; use an absolute path.
            sshKey = "/Users/${username}/.ssh/id_ratatoskr";
            systems = [ "aarch64-linux" ];
            maxJobs = 2;
            speedFactor = 1;
            supportedFeatures = [
              "big-parallel"
              "benchmark"
            ];
          }
        ];

        settings = {
          trusted-users = [
            "root"
            username
          ];
          auto-optimise-store = true;
          allowed-uris = vars.nixAllowedUris;
          substituters = vars.nixSubstitutersPublic;
          trusted-public-keys = vars.nixTrustedPublicKeysPublic;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          keep-outputs = true;
          keep-derivations = true;
          warn-dirty = false;
          builders-use-substitutes = true;
        };
      };

      system.stateVersion = 6;
    };
}
