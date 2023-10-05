{ pkgs, lib, ... }:

{
    services.xserver.enable = true;
    services.xserver.displaymanager.gdm.enable = true;
    services.xservicer.desktopManager.gnome.enable = true;
}