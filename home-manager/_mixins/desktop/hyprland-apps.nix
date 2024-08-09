{ config, pkgs, ... }: {
  imports = [
    ./eww.nix
    ./gtk.nix
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