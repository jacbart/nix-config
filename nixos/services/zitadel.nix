{ config, pkgs, ... }: let
  domain = "meep.sh";
  user = "zitadel";
  group = "zitadel";
in {
  sops.secrets.zitadel-master-key = {
    owner = user;
    group = group;
  };
  
  imports = [
    ./cockroachdb.nix
  ];

  services.zitadel = {
    enable = true;
    package = pkgs.unstable.zitadel;
    openFirewall = true;
    user = user;
    group = group;
    masterKeyFile = config.sops.secrets.zitadel-master-key.path;
    tlsMode = "external";
    settings = {
      Port = 8123;
      ExternalPort = 443;
      ExternalDomain = "zitadel.${domain}";
      ExternalSecure = true;
      Database.cockroach.Host = "localhost:26257";
      Telemetry.Enabled = false;
    };
  };
}
