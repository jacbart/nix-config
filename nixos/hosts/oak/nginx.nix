{...}:
let
  # port = 443;
  domain = "meep.sh";
  # address = "100.116.178.48";
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      # "${domain}" = {
      #   addSSL = true;
      #   useACMEHost = domain;
      #   locations."/.well-known/matrix/server" = {
      #     extraConfig = ''
      #       default_type applicaiton/json;
      #       add_header "Access-Control-Allow-Origin" *;
      #       return 200 '{ "m.server": "matrix.${domain}:${builtins.toString(port)}" }';
      #     '';
      #   };
      #   locations."/.well-known/matrix/client" = {
      #     extraConfig = ''
      #       default_type applicaiton/json;
      #       add_header "Access-Control-Allow-Origin" *;
      #       return 200 '{ "m.homeserver": { "base_url": "https://matrix.${domain}:${builtins.toString(port)}" } }';
      #     '';
      #   };
      # };
      # "matrix.${domain}" = {
      #   addSSL = true;
      #   useACMEHost = domain;
      #   http2 = true;
      #   listen = [{
      #     addr = "0.0.0.0";
      #     port = port;
      #     ssl = true;
      #   }];
      #   locations."/_matrix" = {
      #     proxyPass = "http://${address}:8008";
      #     extraConfig = ''
      #       proxy_set_header X-Forwarded-For $remote_addr;
      #       proxy_set_header X-Forwarded-Proto $scheme;
      #       proxy_set_header Host $host:$server_port;
      #       client_max_body_size 50M;
      #     '';
      #   };
      # };
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
        };
      };
    };
  };
}
