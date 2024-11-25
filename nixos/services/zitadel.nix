{ config
, pkgs
, ...
}:
let
  domain = "meep.sh";
  user = "zitadel";
  group = "zitadel";
in
{
  sops.secrets.zitadel-master-key = {
    owner = user;
    inherit group;
  };

  imports = [
    # ./cockroachdb.nix
    ./postgresql.nix
  ];

  services.zitadel = {
    enable = true;
    package = pkgs.unstable.zitadel;
    openFirewall = true;
    inherit user;
    inherit group;
    masterKeyFile = config.sops.secrets.zitadel-master-key.path;
    tlsMode = "external";
    settings = {
      Port = 8123;
      ExternalPort = 443;
      ExternalDomain = "zitadel.${domain}";
      ExternalSecure = true;
      TLS.Enabled = false;
      Database.postgres = {
        Host = "localhost";
        Port = 5432;
        Database = "zitadel";
        MaxOpenConns = 15;
        MaxIdleConns = 12;
        MaxConnLifetime = "30m";
        MaxConnIdleTime = "5m";
        User = {
          Username = "zitadel";
          Password = "zitadel";
          SSL.Mode = "disable";
        };
        Admin = {
          Username = "postgres";
          Password = "postgres";
          SSL.Mode = "disable";
        };
      };
      Telemetry.Enabled = false;
    };
    steps = {
      FirstInstance = {
        Skip = true;
        DefaultLanguage = "en";
        InstanceName = "ZITADEL";
        Org = {
          Name = "z";
          Human = {
            UserName = "jack";
            FirstName = "Jack";
            LastName = "Bartlett";
            Email = {
              Address = "jack@meep.sh";
              Verified = true;
            };
            Password = "Password!23";
          };
        };
      };
    };
  };
}
