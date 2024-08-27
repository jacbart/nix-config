{ config, pkgs, hostname, ... }:
let
  domain = "meep.sh";
in
{
  environment.etc."nextcloud-admin-pass".text = "CHANGEME";
  # systemd.tmpfiles.rules = [
  #   "f /var/lib/nextcloud/config/CAN_INSTALL 0644 nextcloud nextcloud - -"
  # ];
  
  services = {
    nextcloud = {
      enable = true;
      https = false;
      hostName = "${hostname}.${domain}";
      package = pkgs.nextcloud29;
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
      maxUploadSize = "10G";
      settings = {
        # log_type = "file";
        trusted_domains = [
          "${hostname}.bbl.systems"
          "${hostname}"
        ];
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
