_:
let
  domain = "meep.sh";
  maple = "100.116.178.48";
in
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    upstreams = {
      "matrix-server".servers."${maple}:8008" = { };
      "auth-server".servers."${maple}:8008" = { };
      "tunnel".servers."127.0.0.1:9000" = { };
    };
    virtualHosts = {
      "${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        # locations."/robots.txt" = {
        #   extraConfig = ''
        #     rewrite ^/(.*)  $1;
        #     return 200 "User-agent: *\nDisallow: /";
        #   '';
        # };
        locations."/.well-known/matrix/server" = {
          extraConfig = ''
            default_type applicaiton/json;
            add_header "Access-Control-Allow-Origin" *;
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
        useACMEHost = "matrix.${domain}";
        locations."/_matrix" = {
          proxyPass = "http://matrix-server";
        };
      };
      "tun.${domain}" = {
        addSSL = true;
        useACMEHost = "tun.${domain}";
        locations."/" = {
          proxyPass = "http://tunnel";
        };
      };
    };
  };
}
