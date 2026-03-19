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
    clientMaxBodySize = "0";
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8235";
        extraConfig = ''
          proxy_max_temp_file_size 0;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 300s;
        '';
      };
    };
  };
}
