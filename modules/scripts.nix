# Scripts Module - Dendritic Pattern
# Exports custom scripts as flake.packages

{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import ./scripts { inherit pkgs; };
    };
}
