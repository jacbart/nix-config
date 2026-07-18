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

  einkPush = pkgs.freshrss-extensions.buildFreshRssExtension {
    FreshRssExtUniqueId = "EinkPush";
    pname = "eink-push";
    version = "1.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "SHU-red";
      repo = "xExtension-EinkPush";
      rev = "v1.2.0";
      hash = "sha256-f3IbMZok4965wb0uG9suSJpBuHKaWjElG6liYhpLMyY=";
    };
    meta = {
      description = "Export FreshRSS articles as EPUB for e-ink readers";
      homepage = "https://github.com/SHU-red/xExtension-EinkPush";
      license = lib.licenses.unlicense;
    };
  };
in
{
  # nixos-25.11 FreshRSS module has no services.freshrss.api; enable Reader API under FreshRSS → Authentication after install if needed.

  services.freshrss = {
    enable = true;
    baseUrl = "https://${subdomain}.${domain}";
    authType = "form";
    virtualHost = "${subdomain}.${domain}";
    webserver = "nginx";
    defaultUser = "ratatoskr";
    # Web UI login for defaultUser; reapplied on switch via freshrss-config (update-user).
    passwordFile = config.sops.secrets."freshrss/admin-password".path;
    # database = {
    #   type = "pgsql";
    #   host = "/run/postgresql";
    #   name = "freshrss";
    #   user = "freshrss";
    # };
    extensions =
      with pkgs.freshrss-extensions;
      [
        youtube
      ]
      ++ [ einkPush ];
  };

  sops.secrets."freshrss/admin-password" = {
    owner = config.services.freshrss.user;
  };

  services.nginx.virtualHosts."${subdomain}.${domain}" = {
    addSSL = true;
    useACMEHost = domain;
  };

  # systemd.services.freshrss-config.after = [ "postgresql.service" ];
  # systemd.services.freshrss-config.requires = [ "postgresql.service" ];
}
