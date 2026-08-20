# Attic — self-hosted, multi-tenant Nix binary cache.
# Runs on maple with local storage (on the `trunk` ZFS pool — create a dataset:
#   zfs create trunk/atticd -o mountpoint=/var/lib/atticd/storage
# ). The cache is kept PRIVATE: pulls require a JWT (distributed as a netrc
# via sops to every NixOS host — see modules/nixos/core.nix).  Pushes use a
# separate JWT (see attic-watch-store.nix).
#
# maple's nginx terminates TLS for nix-cache.meep.sh using the wildcard
# *.meep.sh ACME cert (acme-base.nix).  oak reverse-proxies the public path
# to maple over Tailscale (oak/nginx.nix).
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

  # environmentFile must define ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64
  # (generate with: openssl rand 64 | base64 -w0).  Stored in nix-secrets
  # as `attic/token` (env-file format: VAR=value).
  sops.secrets."attic/token" = {
    group = "atticd";
    mode = "0440";
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets."attic/token".path;
    mode = "monolithic";
    settings = {
      listen = "${addr}:${port}";
      api-endpoint = "https://nix-cache.${vars.domain}";
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
