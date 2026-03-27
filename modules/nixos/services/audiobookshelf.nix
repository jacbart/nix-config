{ pkgs, vars, ... }:
let
  package = pkgs.unstable.audiobookshelf;
  subdomain = "books";
  domain = vars.domain;
in
{
  environment.systemPackages = [ package ];

  services.audiobookshelf = {
    enable = true;
    inherit package;
    group = "media";
    host = "127.0.0.2";
    port = 8234;
    openFirewall = false;
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8234";
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
