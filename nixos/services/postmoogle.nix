{ config, pkgs, ... }: let
  user = "moogle";
  group = "moogle";
  dataDir = "postmoogle";
  package = pkgs.postmoogle;
  domain = "meep.sh";
  secretOpts = {
    owner = user;
    inherit group;
  };
in {
  environment.systemPackages = [
    package
    pkgs.sqlite
  ];

  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
  };

  users.groups."${group}" = {
    members = [ user "ratatoskr" ];
  };

  sops.secrets."postmoogle/shared-secret" = secretOpts;
  sops.secrets."postmoogle/data-secret" = secretOpts; 
  sops.secrets."postmoogle/dkim/private-key" = secretOpts;
  sops.secrets."postmoogle/dkim/signature" = secretOpts;

  sops.templates."postmoogle-env-file" = {
    owner = user;
    # openssl genrsa -out dkim_private.pem 2048
    # openssl ec -in dkim_private.pem -pubout -outform der | openssl base64 -A
    content = ''
      export POSTMOOGLE_HOMESERVER="https://matrix.${domain}"
      export POSTMOOGLE_LOGIN="@${user}:${domain}"
      export POSTMOOGLE_PASSWORD="${config.sops.placeholder."postmoogle/shared-secret"}"
      export POSTMOOGLE_DOMAINS="${domain}"
      export POSTMOOGLE_DATA_SECRET="${config.sops.placeholder."postmoogle/data-secret"}"
      export POSTMOOGLE_DB_DSN="local.db"
      export POSTMOOGLE_DB_DIALECT="sqlite3"
      export POSTMOOGLE_ADMINS="@*:${domain}"
      export POSTMOOGLE_DKIM_PRIVKEY="${config.sops.placeholder."postmoogle/dkim/private-key"}"
      export POSTMOOGLE_DKIM_SIGNATURE="${config.sops.placeholder."postmoogle/dkim/signature"}"
    '';
    path = "/var/lib/${dataDir}/.env";
  };

  systemd.services.postmoogle = {
    description = "An Email to Matrix bridge. 1 room = 1 mailbox.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = group;
      StateDirectory = dataDir;
      WorkingDirectory = "/var/lib/${dataDir}";
      ExecStart = ''
        ${package}/bin/postmoogle 
      '';
      Restart = "on-failure";
    };
  };

  networking.firewall.allowedTCPPorts = [
    25 # smtp port
    # 587 # tls port
  ];

  systemd.tmpfiles.rules = [
    "f /var/lib/${dataDir}/local.db 0600 ${user} ${group}"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."mx.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:25";
      };
    };
  };
}
