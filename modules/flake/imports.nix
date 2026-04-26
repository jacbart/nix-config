# Flake-parts modules: perSystem outputs, vars, registries, and shared module exports.
# Add new non-host modules here; host entries go in `modules/hosts/imports.nix`.
{ ... }:
{
  imports = [
    ./overlays.nix
    ./devshell.nix
    ./formatter.nix
    ./systems.nix
    ../vars.nix
    ../configurations.nix
    ../pkgs.nix
    ../scripts.nix

    # Core modules that export to flake.modules
    ../nixos/core.nix
    ../nixos/service-profiles.nix
    ../home/core.nix
    ../darwin/core.nix
    ../darwin/nix-homebrew.nix
    ../darwin/docker.nix
    ../darwin/laptop.nix
  ];
}
