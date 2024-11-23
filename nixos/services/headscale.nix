{ pkgs, ... }: {
  services.headscale = {
    enable = true;
    package = pkgs.beta.headscale;
    address = "0.0.0.0";
    port = 8082;
    user = "headscale";
    group = "headscale";
    settings = {
      server_url = "https://hs.meep.sh:443";
      dns_config.base_domain = "meep.sh";
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
        issuer = "zitadel.meep.sh";
        client_id = "";
        client_secret_path = "";
        scope = [ "openid" "profile" "" ];
      };
    };
  };
}
