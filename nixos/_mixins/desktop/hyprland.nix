{config, pkgs, ...}: {
  imports = [
  ];

  programs.hyprland = {
    enable = true;
    xwayland = {
      hidpi = true;
      enable = true;
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}