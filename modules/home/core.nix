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
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        settings = {
          trusted-users = [
            username
            "root"
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          allowed-uris = vars.nixAllowedUris;
          keep-outputs = true;
          keep-derivations = true;
          warn-dirty = false;
          substituters = vars.nixSubstitutersPublic;
          trusted-public-keys = vars.nixTrustedPublicKeysPublic;
        };
      };
    };
}
