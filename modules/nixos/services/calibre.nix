{
  pkgs,
  # lib,
  vars,
  ...
}:
let
  subdomain = "calibre";
  addr = "127.0.0.2";
  port = 8235;
  domain = vars.domain;
in
{
  services.calibre-web = {
    enable = true;
    package = pkgs.calibre-web;
    group = "media";
    listen = {
      ip = addr;
      inherit port;
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
        proxyPass = "http://${addr}:${builtins.toString port}";
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
