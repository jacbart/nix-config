_:
let
  domain = "meep.sh";
  address = "100.116.178.48";
in
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${domain}" = {
        # enableACME = true;
        # forceSSL = true;
        addSSL = true;
        useACMEHost = domain;
        locations."/.well-known/matrix/server" = {
          extraConfig = ''
            default_type application/json;
            return 200 '{ "m.server": "matrix.${domain}:443" }';
          '';
        };
        locations."/.well-known/matrix/client" = {
          extraConfig = ''
            default_type applicaiton/json;
            add_header "Access-Control-Allow-Origin" *;
            return 200 '{ "m.homeserver": { "base_url": "https://matrix.${domain}" } }';
          '';
        };
      };
      "matrix.${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        locations."/_matrix/" = {
          proxyPass = "http://${address}:8008";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host:$server_port;
            client_max_body_size 50M;
          '';
        };
      };
      "mx.${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        locations."/" = {
          proxyPass = "http://${address}:25";
        };
      };
    };
  };
}
