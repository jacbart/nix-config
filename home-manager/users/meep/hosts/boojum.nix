{ pkgs, ... }: {
  home.packages = with pkgs; [
    powertop
    anytype
  ];
}
