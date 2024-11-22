_: {
  imports = [ ./acme.nix ];

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    logError = "stderr info";
    virtualHosts = {
      # "bbl.systems" = {
      #   # forceSSL = true;
      #   addSSL = true;
      #   useACMEHost = "bbl.systems";
      #   # All serverAliases will be added as extra domain names on the certificate.
      #   serverAliases = [ "*.bbl.systems" ];
      #   acmeRoot = "/var/lib/acme/challenges-bbl";
      #   locations."/" = { root = "/var/www/bbl.systems"; };
      #   # listen = [ { addr = "0.0.0.0"; port = 443; ssl = true;} { addr = "[::0]"; port = 443; ssl = true;} ];
      #   #sslCertificate = "/var/lib/acme/bbl.systems/fullchain.pem";
      #   #sslCertificateKey = "/var/lib/acme/bbl.systems/key.pem";
      #   #sslTrustedCertificate = "/var/lib/acme/bbl.systems/chain.pem";
      # };
      # "bbl.systems80" = {
      #   serverName = "bbl.systems";
      #   serverAliases = [ "*.bbl.systems" ];
      #   locations."/.well-known/acme-challenge" = {
      #     root = "/var/lib/acme/challenges-bbl";
      #     extraConfig = ''
      #       auth_basic off;
      #     '';
      #   };
      #   locations."/" = { return = "301 https://$host$request_uri"; };
      #   listen = [ { addr = "0.0.0.0"; port = 80; } { addr = "[::0]"; port = 80; } ];
      # };
      "meep.sh" = {
        addSSL = true;
        useACMEHost = "meep.sh";
        serverAliases = [ "*.meep.sh" ];
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://localhost:9001";
        };
      };
      "meep.sh80" = {
        serverName = "meep.sh";
        serverAliases = [ "*.meep.sh" ];
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/challenges-meep";
          extraConfig = ''
            auth_basic off;
          '';
        };
        locations."/" = { return = "301 https://$host$request_uri"; };
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          {
            addr = "[::0]";
            port = 80;
          }
        ];
      };
    };
  };
}
