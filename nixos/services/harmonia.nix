{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.harmonia.nixosModules.harmonia ];

  sops.secrets."harmonia-secret" = {
    group = "harmonia";
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;

    virtualHosts."nix-cache.${vars.domain}" = {
      useACMEHost = vars.domain;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };

  services.harmonia-dev = {
    daemon.enable = true;

    cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."harmonia-secret".path ];
      settings = {
        priority = 30;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  users.groups.harmonia = { };
}
