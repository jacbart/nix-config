{ config, pkgs, ... }: {
  imports = [
    # ./eww.nix
    ./kitty.nix
    ./rofi-wayland.nix
  ];

  home = {
    packages = with pkgs; [
      dunst
      libnotify
      swww
    ];

    file."${config.xdg.dataHome}/images/moose-orange-bg.jpg".source = ./moose-orange-bg.jpg;
  };
}
