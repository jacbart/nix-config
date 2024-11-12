{ pkgs, ... }: {
  home.packages = [
    pkgs.powertop
    pkgs.unstable.anytype
  ];
}
