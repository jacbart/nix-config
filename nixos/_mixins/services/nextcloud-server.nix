{ config, pkgs, ... }:
let
  nextcloud-package = pkgs.nextcloud29;
  host = "maple";
  domain = "meep.sh";
  # location = "/trunk/nextcloud";
in
{
  environment.etc."nextcloud-admin-pass".text = "CHANGEME";
  
  services = {
    nextcloud = {
      enable = true;
      https = false;
      hostName = "${host}.${domain}";
      package = nextcloud-package;
      # home = location;
      configureRedis = true;
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = "/etc/nextcloud-admin-pass";
      };
      appstoreEnable = true;
      autoUpdateApps.enable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
      };
      extraAppsEnable = true;
      settings = {
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
      };
    };
  };
}
