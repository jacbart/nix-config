{ config, pkgs, ... }: {
  imports = [
  ];

  programs = {
    waybar = {
      enable = true;
      package = pkgs.waybar;
    };
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "wezterm";
      theme = "DarkBlue";
    };
  };

  home = {
    packages = with pkgs; [
      kitty
      dunst
      libnotify
    ];

    # waybar
    file."${config.xdg.configHome}/waybar/config".text = builtins.readFile ./waybar/config;
    file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
  };
}