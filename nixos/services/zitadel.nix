{ config
, pkgs
, ...
}:
let
  instance = "maple";
  subdomain = "auth";
  domain = "meep.sh";
  user = "zitadel";
  group = "zitadel";
  package = pkgs.zitadel;
in
{
  sops.secrets.zitadel-master-key = {
    owner = user;
    inherit group;
  };

  imports = [
    ./postgresql.nix
  ];

  systemd.services.zitadel.after = [ "postgresql.service" ];
  systemd.services.zitadel.requires = [ "postgresql.service" ];

  # add zitadel to path
  environment.systemPackages = [ package ];

  services.zitadel = {
    enable = true;
    inherit package user group;
    openFirewall = true;
    masterKeyFile = config.sops.secrets.zitadel-master-key.path;
    tlsMode = "external";
    settings = {
      Port = 8123;
      ExternalPort = 443;
      ExternalDomain = "${subdomain}.${domain}";
      ExternalSecure = true;
      # InstanceHostHeaders = [
      #   instance
      # ];
      # PublicHostHeaders = [ ];
      # TLS.Enabled = false;
      Database.postgres = {
        Host = "/run/postgresql";
        Port = 5432;
        Database = "zitadel";
        MaxOpenConns = 15;
        MaxIdleConns = 12;
        MaxConnLifetime = "30m";
        MaxConnIdleTime = "5m";
        User = {
          Username = user;
          # Password = "zitadel";
          SSL.Mode = "disable";
        };
        Admin = {
          Username = "postgres";
          # Password = "postgres";
          SSL.Mode = "disable";
        };
      };
      Telemetry.Enabled = false;
    };
    steps = {
      FirstInstance = {
        Skip = true;
        DefaultLanguage = "en";
        InstanceName = instance;
        Org = {
          Name = "arbor";
          Human = {
            UserName = "jack";
            FirstName = "Jack";
            LastName = "Bartlett";
            Email = {
              Address = "jack@${domain}";
              Verified = true;
            };
            Password = "Password!23";
          };
        };
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
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
