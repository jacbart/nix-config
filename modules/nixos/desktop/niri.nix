{ pkgs, username, ... }:
{
  programs.niri.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  # XDG portals for flatpak, file dialogs, etc.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  services.greetd = {
    enable = true;
    package = pkgs.greetd;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "${username}";
      };
      default_session = initial_session;
    };
  };

  # Noctalia requirements
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    unstable.ghostty
    fuzzel
    swaylock
    swayidle
    cliphist
    wlsunset
    wl-clipboard
    grim
    slurp
    unstable.gnome-software
  ];
}
