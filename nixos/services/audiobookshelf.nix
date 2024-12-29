{ pkgs, ... }:
let
  package = pkgs.unstable.audiobookshelf;
in
{
  environment.systemPackages = [ package ];

  # Since this is using nextcloud's user we need nextcloud-setup first
  # systemd.services.audiobookshelf.requires = [ "nextcloud-setup.service" ];
  # systemd.services.audiobookshelf.after = [ "nextcloud-setup.service" ];

  services.audiobookshelf = {
    enable = true;
    inherit package;
    host = "0.0.0.0";
    port = 8234;
    openFirewall = true;
  };
}
