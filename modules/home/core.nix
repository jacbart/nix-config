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
        overlays = [
          overlays.local-packages
          overlays.script-packages
          overlays.modifications
          overlays.unstable-packages
        ];
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      nix = lib.mkMerge [
        {
          package = if isDarwin then pkgs.nix else pkgs.lixPackageSets.latest.lix;
          settings = {
            trusted-users = [
              username
              "root"
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
          };
        }
        (lib.optionalAttrs (!isDarwin) {
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
        })
      ];
    };
}
