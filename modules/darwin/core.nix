# Darwin Core Module - Dendritic Pattern
# Exports core Darwin configuration as flake.modules.darwin.core

{ ... }:
{
  flake.modules.darwin.core =
    {
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

      nixpkgs = {
        overlays = lib.attrValues overlays;
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

      nix = {
        package = pkgs.lixPackageSets.stable.lix;
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
            # "https://nix-cache.${vars.domain}"
            "https://nix-community.cachix.org"
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            # "nix-cache.${vars.domain}-1:q58+Lt6h68AmBke4wpJatSrpe1cZvDzVNDTp8qurEbs="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
