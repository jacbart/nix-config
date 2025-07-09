{...}:
let
  port = 443;
  domain = "meep.sh";
  address = "100.116.178.48"; # maple
in
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "${domain}" = {
        default = true;
        addSSL = true;
        useACMEHost = domain;
        locations."/robots.txt" = {
          extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        };
        locations."/.well-known/matrix/server" = {
          extraConfig = ''
            default_type applicaiton/json;
            add_header "Access-Control-Allow-Origin" *;
            return 200 '{ "m.server": "matrix.${domain}:${builtins.toString(port)}" }';
          '';
        };
        locations."/.well-known/matrix/client" = {
          extraConfig = ''
            default_type applicaiton/json;
            add_header "Access-Control-Allow-Origin" *;
            return 200 '{ "m.homeserver": { "base_url": "https://matrix.${domain}:${builtins.toString(port)}" } }';
          '';
        };
      };
      "matrix.${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        http2 = true;
        locations."/_matrix" = {
          proxyPass = "http://${address}:8008";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host:$server_port;
            client_max_body_size 50M;
          '';
        };
      };
      # "mx.${domain}" = {
      #   addSSL = true;
      #   useACMEHost = domain;
      #   locations."/" = {
      #     proxyPass = "http://${address}:25";
      #   };
      # };
      "tun.${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;"
            ;
        };
      };
    };
  };
}
