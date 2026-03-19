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
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_max_temp_file_size 0;
          proxy_read_timeout 300s;
        '';
      };
    };
  };
}
