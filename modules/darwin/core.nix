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
        nixos-rebuild-ng
        jq
      ];

      programs.zsh.enable = true;

      # SSH host keys for all fleet builders (MITM protection for the build
      # channel).  Generated from vars.builderHostKeys; colima is added
      # separately by colima.nix.
      programs.ssh.knownHosts = lib.mapAttrs (name: key: {
        hostNames = [ name ] ++ lib.optional (name == "maple") "maple.meep.sh";
        publicKey = key;
      }) vars.builderHostKeys;

      # Fail fast on unreachable builders (see distributed-builds.nix for the
      # NixOS equivalent).  Written to /etc/ssh/ssh_config.d/, read by root's
      # nix-daemon when it SSHes to remote builders.
      programs.ssh.extraConfig = ''
        Host ${lib.concatStringsSep " " (map (m: m.hostName) vars.builders)}
          ConnectTimeout 10
          ServerAliveInterval 15
          ServerAliveCountMax 3
      '';

      nixpkgs = {
        overlays = lib.attrValues overlays;
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

      nix = {
        package = pkgs.lixPackageSets.stable.lix;
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        gc = {
          automatic = true;
          options = "--delete-older-than 10d";
        };
        optimise.automatic = true;

        # Deploying NixOS from this Mac requires delegating linux drvs to a
        # linux builder.  Use the full fleet from vars.builders (all linux
        # builders) so darwin can offload to cork/boojum/etc. via Tailscale.
        distributedBuilds = true;
        buildMachines = map (m: {
          inherit (m)
            hostName
            systems
            speedFactor
            maxJobs
            supportedFeatures
            publicHostKey
            ;
          protocol = "ssh-ng";
          sshUser = "remotebuild";
          sshKey = "/Users/${username}/.ssh/id_remotebuild";
        }) vars.builders;

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

          # Cache/builder outage resilience (see modules/nixos/core.nix).
          fallback = true;
          max-connect-timeout = 15;
          download-attempts = 3;
        };
      };

      system.stateVersion = 6;
    };
}
