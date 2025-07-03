{ config
, pkgs
, ...
}: let
  domain = "meep.sh";
in {
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
    httpPort = 8008;
    # openRegistration = true;
    environmentFile = config.sops.secrets."matrix/env_file".path;
    settings = {
      global = {
        server_name = domain;
        private_key = config.sops.secrets."matrix/private_key".path;
        
      };
      client_api.registration_disabled = true;
      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET"; # in the environmentFile
    };
  };
  # systemd.services.dendrite = {
  #   serviceConfig.SupplementaryGroups = [ config.users.groups.dendrite.name ];
  # };
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/private/dendrite 0755 ${config.users.users.dendrite.name} ${config.users.groups.dendrite.name}"
  # ];
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${domain}" = {
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
      # "matrix.${domain}" = {
      #   addSSL = true;
      #   useACMEHost = domain;
      #   locations."/_matrix/" = {
      #     proxyPass = "http://127.0.0.1:8008";
      #   };
      # };
    };
  };
}
