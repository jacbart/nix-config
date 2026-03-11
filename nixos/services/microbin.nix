{ pkgs, vars, ... }:
{
  services.microbin = {
    enable = true;
    package = pkgs.microbin;
    dataDir = "/var/lib/microbin";
    settings = {
      MICROBIN_HIDE_LOGO = false;
      MICROBIN_PORT = 8283;
      MICROBIN_NO_LISTING = false;
      MICROBIN_PRIVATE = true;
      MICROBIN_HIGHLIGHTSYNTAX = true;
      MICROBIN_SHOW_READ_STATS = true;
      # MICROBIN_READONLY = true;
      MICROBIN_THREADS = 1;
      MICROBIN_GC_DAYS = 0; # 0 is off
      MICROBIN_ENABLE_BURN_AFTER = true;
      MICROBIN_DEFAULT_BURN_AFTER = 0; # no limit
      MICROBIN_QR = true;
      MICROBIN_ETERNAL_PASTA = true;
      MICROBIN_ENABLE_READONLY = true;
      MICROBIN_HASH_IDS = true;
      MICROBIN_MAX_FILE_SIZE_ENCRYPTED_MB = 4096;
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 10240;
      MICROBIN_DISABLE_TELEMETRY = false;
      MICROBIN_LIST_SERVER = false;
      MICROBIN_ADMIN_USERNAME = "admin";
    };
  };
  services.nginx = {
    enable = true;
    virtualHosts."bin.${vars.domain}" = {
      useACMEHost = vars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8283";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
  };
}
