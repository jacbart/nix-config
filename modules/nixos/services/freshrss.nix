{
  pkgs,
  lib,
  vars,
  config,
  ...
}:
let
  subdomain = "rss";
  domain = vars.domain;
in
{
  services.freshrss = {
    enable = true;
    # Google Reader API (/api/greader.php); must match Profile → API password in the UI, not the web login password.
    api.enable = true;
    baseUrl = "https://${subdomain}.${domain}";
    authType = "form";
    virtualHost = "${subdomain}.${domain}";
    webserver = "nginx";
    defaultUser = "ratatoskr";
    # Web UI login for defaultUser; reapplied on switch via freshrss-config (update-user).
    passwordFile = config.sops.secrets."freshrss/admin-password".path;
    database = {
      type = "pgsql";
      host = "/run/postgresql";
      name = "freshrss";
      user = "freshrss";
    };
    extensions = with pkgs.freshrss-extensions; [
      youtube
    ];
  };

  sops.secrets."freshrss/admin-password" = {
    owner = config.services.freshrss.user;
  };

  services.nginx.virtualHosts."${subdomain}.${domain}" = {
    addSSL = true;
    useACMEHost = domain;
  };

  systemd.services.freshrss-config.after = [ "postgresql.service" ];
  systemd.services.freshrss-config.requires = [ "postgresql.service" ];
}
