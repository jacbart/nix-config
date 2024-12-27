{ config
, pkgs
, lib
, ...
}:
let
  subdomain = "cloud";
  domain = "meep.sh";
in
{
  sops.secrets.nextcloud-admin-password = {
    owner = "nextcloud";
    group = "nextcloud";
  };

  imports = [ ./postgresql.nix ];
  systemd.services.nextcloud-setup.after = [ "postgresql.service" ];
  systemd.services.nextcloud-setup.requires = [ "postgresql.service" ];

  services = {
    nextcloud = {
      enable = true;
      https = false;
      hostName = "${subdomain}.${domain}";
      package = pkgs.nextcloud30;
      configureRedis = true;
      database.createLocally = false; # Use postgresql.nix as db
      config = {
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };
      phpOptions = lib.mkForce {
        "default_locale" = "en_US";
        "opcache.revalidate_freq" = 4;
        "opcache.interned_strings_buffer" = 512;
        "opcache.max_accelerated_files" = 10000;
        "opcache.memory_consumption" = 1024;
        "maintenance_window_start" = 1;
        "apc.enable_cli" = 1;
        "output_buffering" = 0;
        "memory_limit" = "102400M";
        "upload_max_filesize" = "102400M";
        "post_max_size" = "102400M";
        "max_input_time" = 360000;
        "max_execution_time" = 360000;
      };
      appstoreEnable = true;
      autoUpdateApps.enable = false;
      extraApps = with pkgs.nextcloud30Packages.apps; {
        inherit bookmarks cookbook notes notify_push maps music previewgenerator contacts calendar tasks twofactor_webauthn unroundedcorners;
      };
      extraAppsEnable = true;
      settings = {
        # log_type = "systemd";
        overwriteprotocol = "https";
        default_phone_region = "US";
        trusted_domains = [ "cloud.meep.sh" ];
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
