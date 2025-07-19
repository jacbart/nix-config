{ pkgs, ... }:
{
  home.packages = [
    pkgs.unstable.libation
    pkgs.unstable.anytype
    pkgs.freecad
  ];
}
