{
  config,
  vars,
  ...
}:
{

  sops.secrets."harmonia/secret" = {
    group = "harmonia";
  };
  sops.secrets."harmonia/pub" = {
    group = "harmonia";
  };

  services.harmonia = {
    enable = true;
    cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."harmonia/secret".path ];
      settings = {
        priority = 30;
      };
    };
  };

  users.groups.harmonia = { };
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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
