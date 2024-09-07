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
  # environment.etc."nextcloud-admin-pass".text = "CHANGEME";
  # systemd.tmpfiles.rules = [
  #   "f /var/lib/nextcloud/config/CAN_INSTALL 0644 nextcloud nextcloud - -"
  # ];
  
  services = {
    # nginx = {
    #   enable = true;
    #   virtualHosts = {
    #     "${subdomain}.${domain}" = {
    #       enableACME = true;
    #       acmeRoot = null;
    #     };
    #   };
    # };
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
        # uncomment to display logs in nextcloud app
        # log_type = "file";
        # trusted_domains = [
        #   "${hostname}.bbl.systems"
        #   "${hostname}"
        # ];
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
