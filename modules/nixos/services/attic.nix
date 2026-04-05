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
      server = {
        listen = "${addr}:${port}";
        external-url = "https://nix-cache.${vars.domain}";
      };
      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
      gc = {
        interval = "yearly";
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
