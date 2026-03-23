{
  pkgs,
  lib,
  vars,
  ...
}:
let
  subdomain = "calibre";
  domain = vars.domain;
  calibreWebPackage = pkgs.unstable.calibre-web.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ lib.concatLists (lib.attrValues old.optional-dependencies);
  });
in
{
  services.calibre-web = {
    enable = true;
    package = calibreWebPackage;
    group = "media";
    listen = {
      ip = "127.0.0.2";
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
