# Darwin Core Module - Dendritic Pattern
# Exports core Darwin configuration as flake.modules.darwin.core

{ ... }:
{
  flake.modules.darwin.core =
    {
      lib,
      vars,
      overlays,
      username,
      ...
    }:
    {
      users.users = lib.mkDefault { };

      programs.zsh.enable = true;

      nixpkgs = {
        overlays = lib.attrValues overlays;
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

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
            "nix-cache.${vars.domain}-1:q58+Lt6h68AmBke4wpJatSrpe1cZvDzVNDTp8qurEbs="
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
