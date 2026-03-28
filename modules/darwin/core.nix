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
      username,
      ...
    }:
    {
      users.users = lib.mkDefault { };

      programs.zsh.enable = true;

      nixpkgs.hostPlatform = "aarch64-darwin";

      # Attic client for pushing to nix-cache
      environment.systemPackages = [
        inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client
      ];

      nix = {
        gc = {
          automatic = true;
          options = "--delete-older-than 10d";
        };
        optimise.automatic = true;
        settings = {
          trusted-users = [
            "root"
            username
          ];
          substituters = [
            "https://nix-cache.${vars.domain}"
            "https://nix-community.cachix.org"
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            "nix-cache.${vars.domain}-1:XXAOd8QBIGcdFKorIt/nY+MP6DTJWA63h1zFyJfEzQM="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          keep-outputs = true;
          keep-derivations = true;
          warn-dirty = false;
        };
      };

      system.stateVersion = 6;
    };
}
