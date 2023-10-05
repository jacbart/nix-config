{config, pkgs, ...}: {
  imports = [
    ./waybar.nix
  ]

  programs.hyprland = {
    enable = true;
    xwayland = {
      hidpi = true;
      enable = true;
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  rofi-wayland = {
    enable = true;
    theme = pkgs.rofi-themes.flat-orange;
  };
}