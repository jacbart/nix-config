{
  pkgs,
  config,
  vars,
  ...
}:
let
  package = pkgs.unstable.audiobookshelf;
  subdomain = "books";
  domain = vars.domain;

  # Hardcover.app sync sidecar: pushes listening progress, reading status,
  # and ownership from ABS to Hardcover on a schedule. Tokens come from a
  # sops env file (AUDIOBOOKSHELF_TOKEN / HARDCOVER_TOKEN) shared with the
  # CWA unit, so both integrations use the same Hardcover API key.
  #
  # v3.x only syncs profiles stored in its SQLite DB; env-token "single-user"
  # mode never fires the periodic loop by itself. The profile is bootstrapped
  # by migrating a config.yaml (see bootstrapConfig below) into a `default`
  # profile on first start. After that the migration skips (a profile
  # exists), so token/sync-setting changes in the yaml are IGNORED — to
  # rotate: update the sops env file, then on maple:
  #   systemctl stop hardcover-sync \
  #     && rm /var/lib/hardcover-sync/data/audiobookshelf-hardcover-sync.db* \
  #     && systemctl start hardcover-sync
  # (fresh DB re-migrates from the regenerated config.yaml; encryption.key
  # may stay or go, both work.)
  syncPackage = pkgs.audiobookshelf-hardcover-sync;
  syncStateDir = "/var/lib/hardcover-sync";
  syncConfigFile = "${syncStateDir}/config.yaml";

  # Regenerated on every start from the unit's EnvironmentFile tokens.
  # Inert once the profile DB exists (the app copies it to config.yaml.backup.*
  # on first migration and never reads it again).
  bootstrapConfig = pkgs.writeShellScript "hardcover-sync-bootstrap" ''
        set -eu
        ${pkgs.coreutils}/bin/mkdir -p ${syncStateDir}/data ${syncStateDir}/cache ${syncStateDir}/mismatches
        cat > ${syncConfigFile} <<EOF
    audiobookshelf:
      url: http://127.0.0.2:8234
      token: ''${AUDIOBOOKSHELF_TOKEN}
    hardcover:
      token: ''${HARDCOVER_TOKEN}
    sync:
      sync_interval: "10m"
      state_file: ${syncStateDir}/data/sync_state.json
      sync_want_to_read: false
      sync_owned: true
    paths:
      data_dir: ${syncStateDir}/data
      cache_dir: ${syncStateDir}/cache
      mismatch_output_dir: ${syncStateDir}/mismatches
    EOF
        ${pkgs.coreutils}/bin/chmod 600 ${syncConfigFile}
  '';
in
{
  environment.systemPackages = [
    package
    syncPackage
  ];

  sops.secrets."hardcover/env_file" = {
    mode = "0440";
    group = "media";
    restartUnits = [
      "hardcover-sync.service"
      "calibre-web-automated.service"
    ];
  };

  users.users.hardcover-sync = {
    isSystemUser = true;
    group = "media";
    home = syncStateDir;
    description = "Audiobookshelf to Hardcover sync";
  };

  services.audiobookshelf = {
    enable = true;
    inherit package;
    group = "media";
    host = "127.0.0.2";
    port = 8234;
    openFirewall = false;
  };

  systemd.services.hardcover-sync = {
    description = "Audiobookshelf to Hardcover sync";
    after = [
      "network.target"
      "audiobookshelf.service"
    ];
    requires = [ "audiobookshelf.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      AUDIOBOOKSHELF_URL = "http://127.0.0.2:8234";
      SYNC_INTERVAL = "10m";
      # Want to Read is handled by the CWA/Kobo shelf flow; avoid duplicating
      # the whole unstarted ABS library on Hardcover.
      SYNC_WANT_TO_READ = "false";
      SYNC_OWNED = "true";
      # The app defaults these to ./data ./cache ./mismatches relative to the
      # working directory; under ProtectSystem=strict that's read-only, so
      # anchor them in the StateDirectory explicitly.
      DATA_DIR = "${syncStateDir}/data";
      CACHE_DIR = "${syncStateDir}/cache";
      MISMATCH_OUTPUT_DIR = "${syncStateDir}/mismatches";
      # Keep env and migrated-profile state in the same file.
      SYNC_STATE_FILE = "${syncStateDir}/data/sync_state.json";
      LOG_FORMAT = "console";
      SHUTDOWN_TIMEOUT = "30s";
    };

    serviceConfig = {
      Type = "simple";
      User = "hardcover-sync";
      Group = "media";
      WorkingDirectory = syncStateDir;
      EnvironmentFile = config.sops.secrets."hardcover/env_file".path;
      StateDirectory = "hardcover-sync";
      ExecStartPre = [ "${bootstrapConfig}" ];
      ExecStart = "${syncPackage}/bin/audiobookshelf-hardcover-sync --config ${syncConfigFile}";
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:8234";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
  };
}
