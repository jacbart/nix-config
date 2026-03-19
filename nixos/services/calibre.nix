{ vars, ... }:
let
  subdomain = "calibre";
  domain = vars.domain;
in
{
  services.calibre-web = {
    enable = true;
    group = "media";
    listen = {
      ip = "0.0.0.0";
      port = 8235;
    };
    openFirewall = true;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8235";
        extraConfig = ''
          # Disable buffering for smooth downloads
          proxy_buffering off;
          proxy_read_timeout 300s;
        '';
      };
    };
  };
}
