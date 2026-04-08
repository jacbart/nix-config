{ pkgs, username, ... }:
{
  services.displayManager.gdm.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = username;
    group = "users";
    phocConfig.xwayland = "immediate";
    phocConfig.outputs = {
      DSI-1 = {
        rotate = "90";
        scale = 1;
      };
    };
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  environment.systemPackages = with pkgs; [
    baobab # disk usage
    # chatty # XMPP & SMS messaging via libpurple and ModemManager
    decibels # audio player
    epiphany # web browser
    evince # document viewer
    nautilus # files
    gnome-disk-utility
    gnome-calendar
    gnome-calculator
    gnome-console # term
    gnome-contacts
    gnome-clocks
    gnome-music
    gnome-system-monitor
    gnome-weather
    gmobile
    loupe # image viewer
    totem # video player
  ];
}
