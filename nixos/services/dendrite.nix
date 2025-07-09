{ config
, pkgs
, ...
}:
let
  domain = "meep.sh";
  port = 8008;
in
{
  users.users.dendrite = {
    isSystemUser = true;
    group = config.users.groups.dendrite.name;
    home = "/var/lib/private/dendrite";
  };

  users.groups.dendrite = { };

  sops.secrets."matrix/private_key" = {
    mode = "0440";
    group = config.users.groups.dendrite.name;
  };
  sops.secrets."matrix/env_file" = {
    mode = "0440";
    group = config.users.groups.dendrite.name;
  };

  environment.systemPackages = [ pkgs.dendrite ];
  services.dendrite = {
    enable = true;
    httpPort = port;
    # openRegistration = true;
    environmentFile = config.sops.secrets."matrix/env_file".path;
    settings = {
      global = {
        server_name = domain;
        private_key = config.sops.secrets."matrix/private_key".path;
        trusted_third_party_id_servers = [
          "matrix.org"
          "vector.im"
        ];
        well_known_server_name = "matrix.${domain}:443";
        well_known_client_name = "https://matrix.${domain}";
        disable_federation = false;
        presence = {
          enable_inbound = false;
          enable_outbound = false;
        };
      };
      client_api.registration_disabled = true;
      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET"; # in the environmentFile
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];

  # systemd.services.dendrite = {
  #   serviceConfig.SupplementaryGroups = [ config.users.groups.dendrite.name ];
  # };
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/private/dendrite 0755 ${config.users.users.dendrite.name} ${config.users.groups.dendrite.name}"
  # ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "${domain}" = {
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
          proxyPass = "http://localhost:8008";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host:$server_port;
            client_max_body_size 512M;
          '';
        };
      };
    };
  };
}
