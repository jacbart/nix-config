{ pkgs, ... }:
let
  user = "nextcloud";
  group = "nextcloud";
  package = pkgs.unstable.audiobookshelf;
  dataDir = "nextcloud/data/jack/files/Media/Audiobooks"; # path starts with /var/lib/ default is audiobookshelf
in
{
  environment.systemPackages = [ package ];

  # Since this is using nextcloud's user we need nextcloud-setup first
  systemd.services.audiobookshelf.requires = [ "nextcloud-setup.service" ];
  systemd.services.audiobookshelf.after = [ "nextcloud-setup.service" ];

  services.audiobookshelf = {
    enable = true;
    inherit package user group dataDir;
    host = "0.0.0.0";
    port = 8234;
    openFirewall = true;
  };
}
