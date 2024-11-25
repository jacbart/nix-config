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
      server_url = "https://hs.${domain}:443";
      dns.base_domain = domain;
      database = {
        type = "postgres";
        postgres = {
          host = "/run/postgresql";
          port = "5432";
          user = "headscale";
          name = "headscale";
        };
      };
      oidc = {
        only_start_if_oidc_is_available = true;
        issuer = "zitadel.${domain}";
        client_id = "295278622669865221";
        client_secret_path = config.sops.secrets.zitadel-tailscale-client-secret.path;
        scope = [ "openid" "profile" "email" "custom" ];
        strip_email_domain = true;
      };
    };
  };
}
