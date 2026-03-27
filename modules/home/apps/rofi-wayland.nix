{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "kitty";
    theme = "DarkBlue";
    location = "center";
    extraConfig = {
      combi-modes = [
        "drun"
        "window"
        "ssh"
      ];
    };
  };
}
