{
  config,
  pkgs,
  ...
}:
let
  clientid = "";
  domain = "meep.sh";
in
{
  sops.secrets.zitadel-tailscale-client-secret = {
    owner = "headscale";
    group = "headscale";
  };

  services.headscale = {
    enable = true;
    package = pkgs.headscale;
    address = "0.0.0.0";
    port = 8082;
    user = "headscale";
    group = "headscale";
    settings = {
      log = {
        level = "debug";
        format = "text";
      };
      server_url = "https://hs.${domain}";
      # metrics_listen_url = "127.0.0.2:9092";
      grpc_listen_url = "0.0.0.0:50443";
      grpc_allow_insecure = true;
      dns = {
        nameservers.global = [
          "192.168.0.120"
        ];
        base_domain = "net.${domain}";
      };
      database = {
        type = "postgres";
        postgres = {
          host = "/run/postgresql";
          user = "headscale";
          name = "headscale";
        };
      };
      oidc = {
        only_start_if_oidc_is_available = true;
        issuer = "https://auth.${domain}";
        client_id = clientid;
        client_secret_path = config.sops.secrets.zitadel-tailscale-client-secret.path;
        scope = [
          "openid"
          "profile"
          "email"
        ];
      };
    };
  };

  systemd.services.headscale.requires = [ "zitadel.service" ];
  systemd.services.headscale.after = [
    "network-online.target"
    "zitadel.service"
  ];

  networking.firewall = {
    allowedUDPPorts = [
      config.services.headscale.port
      50443
    ];
    allowedTCPPorts = [
      config.services.headscale.port
      50443
    ];
  };

  environment.systemPackages = [
    config.services.headscale.package
  ];
}
