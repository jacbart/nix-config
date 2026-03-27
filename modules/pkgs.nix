# Packages Module - Dendritic Pattern
# Exports custom packages as flake.packages

{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import ./pkgs { inherit pkgs; };
    };
}
