{
  config,
  inputs,
  vars,
  ...
}:
let
  port = "8787";
  addr = "127.0.0.2";
in
{
  imports = [ inputs.attic.nixosModules.atticd ];

  users.groups.atticd = { };

  sops.secrets."attic/token" = {
    group = "atticd";
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets."attic/token".path;
    mode = "monolithic";
    settings = {
      listen = "${addr}:${port}";
      api_endpoint = "https://nix-cache.${vars.domain}";
      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;

    virtualHosts."nix-cache.${vars.domain}" = {
      useACMEHost = vars.domain;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://${addr}:${port};
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
