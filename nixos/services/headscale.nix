{ config
, pkgs
, ... }: 
let domain = "meep.sh";
in {
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
      # metrics_listen_url = "127.0.0.1:9092";
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
        issuer = "https://zitadel.${domain}";
        client_id = "295278622669865221";
        client_secret_path = config.sops.secrets.zitadel-tailscale-client-secret.path;
        scope = [ "openid" "profile" "email" ];
        # allowed_users = [
        #   "jack@meep.sh"
        # ];
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ config.services.headscale.port 50443 ];
    allowedTCPPorts = [ config.services.headscale.port 50443 ];
  };

  environment.systemPackages = [
    config.services.headscale.package
  ];
}
