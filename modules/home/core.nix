# Home Manager Core Module - Dendritic Pattern
# Exports core Home-Manager configuration as flake.modules.homeManager.core

{ ... }:
{
  flake.modules.homeManager.core =
    {
      inputs,
      lib,
      pkgs,
      vars,
      stateVersion,
      username,
      hostname,
      overlays,
      ...
    }@hmConfig:
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      imports = [ ];

      home = {
        activation.report-changes = hmConfig.config.lib.dag.entryAnywhere ''
          ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
        '';
        homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        sessionPath = [ "$HOME/.local/bin" ];
        inherit stateVersion username;
      };

      news.display = "silent";

      nixpkgs = {
        overlays = lib.attrValues overlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      nix = {
        package = pkgs.lixPackageSets.latest.lix;
        settings = {
          trusted-users = [
            username
            "root"
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
        };
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        settings = {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          keep-outputs = true;
          keep-derivations = true;
          warn-dirty = false;
        };
      };
    };
}
