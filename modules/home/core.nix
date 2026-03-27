# Home Manager Core Module - Dendritic Pattern
# Exports core Home-Manager configuration as flake.modules.home.core

{ ... }:
{
  flake.modules.home.core =
    {
      inputs,
      lib,
      pkgs,
      vars,
      stateVersion,
      ...
    }@hmConfig:
    let
      inherit (pkgs.stdenv) isDarwin;
      username = hmConfig.config.home.username;
    in
    {
      imports = [ ];

      home = {
        activation.report-changes = hmConfig.config.lib.dag.entryAnywhere ''
          ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
        '';
        homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        sessionPath = [ "$HOME/.local/bin" ];
        inherit stateVersion;
      };

      news.display = "silent";

      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      nix = {
        package = pkgs.nix;
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
        }
        // lib.optionalAttrs (!isDarwin) {
          registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
          package = pkgs.lixPackageSets.latest.lix;
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
    };
}
