{ pkgs
, ...
}: {
  services.headscale = {
    enable = true;
    package = pkgs.headscale;
    address = "192.168.1.5";
    port = 8082;
    user = "headscale";
    group = "headscale";
    settings = {
      server_url = "https://hs.meep.sh:443";
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
