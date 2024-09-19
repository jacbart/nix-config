{ config, pkgs, lib, ... }:
let
  subdomain = "cloud";
  domain = "meep.sh";
in
{
  sops.secrets.nextcloud-admin-password = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  
  services = {
    nextcloud = {
      enable = true;
      https = false;
      hostName = "${subdomain}.${domain}";
      package = pkgs.nextcloud29;
      configureRedis = true;
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };
      appstoreEnable = true;
      autoUpdateApps.enable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
      };
      extraAppsEnable = true;
      maxUploadSize = "10G";
      settings = {
        overwriteprotocol = "https";
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
