{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.rofi
    pkgs.rofi-systemd
  ];
}
