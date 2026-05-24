{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  subdomain = "photos";
  domain = vars.domain;
  host = "127.0.0.2";
  port = 2283;
  mediaLocation = "/trunk/immich";
in
{
  services.immich = {
    enable = true;
    inherit host port mediaLocation;
    openFirewall = false;
    machine-learning.enable = false;

    database = {
      enable = true;
      createDB = true;
      host = "/run/postgresql";
      name = "immich";
      user = "immich";
    };

    redis.enable = true;

    settings = {
      server.externalDomain = "https://${subdomain}.${domain}";
      newVersionCheck.enabled = false;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${mediaLocation} 0700 immich immich -"
  ];

  systemd.services.immich-server = {
    after = [ "postgresql.target" ];
    requires = [ "postgresql.target" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://${host}:${builtins.toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
