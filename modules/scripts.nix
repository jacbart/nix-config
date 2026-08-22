# Scripts Module - Dendritic Pattern
# Exports custom scripts as flake.packages
#
# Scripts depend on overlay-provided packages (e.g. unstable from
# unstable-packages). The default perSystem pkgs is raw
# nixpkgs.legacyPackages without overlays, so we import nixpkgs with the
# flake's overlays applied to make those packages available.

{ config, inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues config.flake.overlays;
      };
    in
    {
      packages = import ./scripts { inherit pkgs; };
    };
}
