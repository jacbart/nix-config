{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.baobab # disk usage
    pkgs.decibels # audio player
    pkgs.epiphany # web browser
    pkgs.evince # document viewer
    pkgs.nautilus # files
    pkgs.gnome-disk-utility
    pkgs.gnome-calendar
    pkgs.gnome-calculator
    pkgs.gnome-console # term
    pkgs.gnome-contacts
    pkgs.gnome-clocks
    pkgs.gnome-music
    pkgs.gnome-system-monitor
    pkgs.gnome-weather
    pkgs.gmobile
    pkgs.loupe # image viewer
    pkgs.totem # video player
  ];
}
