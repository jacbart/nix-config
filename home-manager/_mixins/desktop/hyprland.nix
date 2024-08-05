{config, pkgs, hardware, ...}: {
  imports = [
  ];

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
  };

  home.sessionVariables = {
    # If your cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
}