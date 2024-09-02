{ ... }: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # other Nginx options
    virtualHosts = {
      "ca.meep.com" =  {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9443";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;"
            ;
        };
      };
      "cloud.meep.com" =  {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:443";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;"
            ;
        };
      };
      "s3.meep.com" =  {
        forceSSL = true;
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
      "minio.meep.sh" =  {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9001";
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
