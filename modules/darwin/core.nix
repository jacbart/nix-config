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
        };
      };

      system.stateVersion = 6;
    };
}
