{ config, pkgs, ... }: {
  imports = [
    ./eww.nix
    ./kitty.nix
    ./rofi-wayland.nix
  ];

  home = {
    packages = with pkgs; [
      dunst
      libnotify
    ];
  };
}