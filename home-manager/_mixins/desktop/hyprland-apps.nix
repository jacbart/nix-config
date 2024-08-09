{ config, pkgs, ... }: {
  imports = [
    ./kitty.nix
    ./waybar.nix
  ];

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "kitty";
      theme = "DarkBlue";
    };
  };

  home = {
    packages = with pkgs; [
      dunst
      libnotify
    ];
  };
}