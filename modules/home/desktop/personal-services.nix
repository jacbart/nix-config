# User-level services shared across personal Wayland desktops.
{ ... }:
{
  imports = [
    ../services/nextcloud-client.nix
    ../services/dunst.nix
  ];
}
