# Packages Module - Dendritic Pattern
# Exports custom packages as flake.packages

{ config, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import ./pkgs { inherit pkgs inputs; };
    };
}
