{ config, pkgs, username, ... }: {
  imports = [
  ];

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
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
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];

  # services.xserver.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };
  services.greetd = {
    enable = true;
    package = pkgs.greetd;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/hyprland";
        user = "${username}";
      };
    };
  };
}