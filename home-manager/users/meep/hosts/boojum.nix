{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.anytype
    pkgs.freecad
  ];
}
