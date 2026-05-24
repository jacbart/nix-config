{
  config,
  lib,
  pkgs,
  ...
}:
let
  backupDir = "/trunk/backups/postgresql";
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [
      "postgres"
      "freshrss"
      "zitadel"
    ];
    ensureUsers = [
      {
        name = "freshrss";
        ensureDBOwnership = true;
      }
      {
        name = "zitadel";
        ensureDBOwnership = true;
      }
    ];
    identMap = ''
      # ArbitraryMapName systemuser DBUser
      superuser_map    zitadel     postgres
      superuser_map    root        postgres
      # Let other names login as themselves
      superuser_map    /^(.*)$     \1
    '';
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method optional_ident_map
      local all        all     peer        map=superuser_map
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${backupDir} 0700 postgres postgres -"
  ];

  systemd.services.postgresql-backup = {
    description = "PostgreSQL nightly dumpall backup";
    after = [ "postgresql.service" "zfs.target" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = pkgs.writeShellScript "postgresql-backup" ''
        ${lib.getExe' config.services.postgresql.package "pg_dumpall"} > "${backupDir}/pg_dumpall_$(date +%Y%m%d).sql"
      '';
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ backupDir ];
      NoNewPrivileges = true;
    };
  };

  systemd.timers.postgresql-backup = {
    description = "Nightly PostgreSQL dumpall backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };

  systemd.services.postgresql-backup-cleanup = {
    description = "Remove PostgreSQL backups older than 7 days";
    after = [ "postgresql-backup.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = "${pkgs.findutils}/bin/find ${backupDir} -name 'pg_dumpall_*' -mtime +7 -delete";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ backupDir ];
      NoNewPrivileges = true;
    };
  };

  systemd.timers.postgresql-backup-cleanup = {
    description = "Daily cleanup of old PostgreSQL backups";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "60min";
    };
  };
}
