{config, pkgs, ...}: {
  imports = [
  ];

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    nvidiaPatches = true;
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
      # Opengl
      opengl.enable = true;

      # Most wayland compositors need this
      nvidia.modesetting.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
}