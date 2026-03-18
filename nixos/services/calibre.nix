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
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8235";
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
