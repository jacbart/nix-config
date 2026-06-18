# Calibre-Web-Automated on maple.
#
# CWA hardcodes /app/calibre-web-automated, /config, /calibre-library,
# /cwa-book-ingest throughout its source (inherited from its Docker image).
# Rather than patch every reference, preStart rsyncs the Nix package tree
# into a writable state directory, and systemd BindPaths maps the writable
# state dir + library + ingest dirs into the expected absolute paths inside
# the unit's mount namespace.
{
  pkgs,
  lib,
  vars,
  ...
}:
let
  subdomain = "calibre";
  addr = "127.0.0.2";
  port = 8235;
  domain = vars.domain;

  user = "calibre-web";
  group = "media";

  stateDir   = "/var/lib/calibre-web-automated";
  configDir  = "${stateDir}/config";
  libraryDir = "${stateDir}/library";
  ingestDir  = "${stateDir}/ingest";
  # Mounted as /app inside the unit. CWA writes /app/theme_migration_notice
  # and /app/cwa_update_notice (siblings of /app/calibre-web-automated),
  # so /app itself must be writable.
  appRoot    = "${stateDir}/app-root";
  appDir     = "${appRoot}/calibre-web-automated";

  cwa = pkgs.calibre-web-automated;

  # Binaries CWA shells out to via subprocess.run / Popen.
  runtimePath = [
    pkgs.python3
    pkgs.calibre
    pkgs.kepubify
    pkgs.inotify-tools
    pkgs.imagemagick
    pkgs.ghostscript
    pkgs.file
    pkgs.sqlite
    pkgs.coreutils
    pkgs.findutils
    pkgs.procps
    pkgs.gnused
  ];

  # NOTE: minimal hardening. CWA shells out to Calibre (Qt-based) which
  # needs /dev access for Qt init even on --version, and ImageMagick which
  # touches many syscalls. PrivateDevices=true silently breaks check_calibre.
  hardenedServiceConfig = {
    NoNewPrivileges = true;
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    LockPersonality = true;
    RestrictSUIDSGID = true;
    RestrictRealtime = true;
    PrivateTmp = true;
  };

  cwaEnv = {
    CALIBRE_DBPATH = "/config";
    CALIBRE_CONFIG_DIR = "/config";
    CWA_PORT_OVERRIDE = toString port;
    HOME = "/config";
    # CWA's editbooks chowns the ingest dir on upload; as a non-root user
    # that's EPERM. The official escape hatch is NETWORK_SHARE_MODE.
    NETWORK_SHARE_MODE = "true";
    # Headless Qt: ebook-convert --version aborts without a platform plugin
    # even though no GUI is needed.
    QT_QPA_PLATFORM = "offscreen";
    XDG_CONFIG_HOME = "/config/.xdg-config";
    XDG_CACHE_HOME  = "/config/.xdg-cache";
    XDG_DATA_HOME   = "/config/.xdg-data";
  };

  bindMounts = {
    BindPaths = [
      "${appRoot}:/app"
      "${configDir}:/config"
      "${libraryDir}:/calibre-library"
      "${ingestDir}:/cwa-book-ingest"
    ];
  };
in
{
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
    home = stateDir;
    description = "Calibre-Web-Automated";
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir}   0750 ${user} ${group} -"
    "d ${configDir}  0750 ${user} ${group} -"
    "d ${libraryDir} 0755 ${user} ${group} -"
    "d ${ingestDir}  0775 ${user} ${group} -"
    "d ${appRoot}    0750 ${user} ${group} -"
    "d ${appDir}     0750 ${user} ${group} -"
    "d ${configDir}/processed_books              0750 ${user} ${group} -"
    "d ${configDir}/processed_books/converted    0750 ${user} ${group} -"
    "d ${configDir}/processed_books/imported     0750 ${user} ${group} -"
    "d ${configDir}/processed_books/failed       0750 ${user} ${group} -"
    "d ${configDir}/processed_books/fixed_originals       0750 ${user} ${group} -"
    "d ${configDir}/processed_books/duplicate_resolutions 0750 ${user} ${group} -"
    "d ${configDir}/log_archive            0750 ${user} ${group} -"
    "d ${configDir}/metadata_temp          0750 ${user} ${group} -"
    "d ${configDir}/.cwa_conversion_tmp    0750 ${user} ${group} -"
    "d ${configDir}/thumbnails             0750 ${user} ${group} -"
    "d ${configDir}/backup                 0750 ${user} ${group} -"
    "d ${configDir}/.xdg-config            0750 ${user} ${group} -"
    "d ${configDir}/.xdg-cache             0750 ${user} ${group} -"
    "d ${configDir}/.xdg-data              0750 ${user} ${group} -"
  ];

  systemd.services.calibre-web-automated = {
    description = "Calibre-Web-Automated";
    after = [ "network.target" "zfs-mount.service" ];
    wants = [ "zfs-mount.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = cwaEnv;
    path = runtimePath;

    serviceConfig = hardenedServiceConfig // bindMounts // {
      Type = "simple";
      User = user;
      Group = group;
      WorkingDirectory = "/app/calibre-web-automated";
      # '+' prefix runs as root, before privileges drop to User=
      ExecStartPre = [
        ("+" + (pkgs.writeShellScript "cwa-pre-start" ''
          set -eu

          # Mirror CWA package tree into writable state dir. Skip rsync if
          # already synced from this exact $cwa store path.
          stamp=${appDir}/.cwa-source-stamp
          want=${cwa}
          if [ ! -f "$stamp" ] || [ "$(${pkgs.coreutils}/bin/cat "$stamp" 2>/dev/null)" != "$want" ]; then
            ${pkgs.rsync}/bin/rsync -a --delete \
              --exclude='dirs.json' \
              --exclude='metadata_change_logs/' \
              --exclude='.cwa-source-stamp' \
              ${cwa}/share/calibre-web-automated/ ${appDir}/
            ${pkgs.coreutils}/bin/install -d -m 0750 ${appDir}/metadata_change_logs
            if [ ! -f ${appDir}/dirs.json ]; then
              ${pkgs.coreutils}/bin/install -m 0640 \
                ${cwa}/share/calibre-web-automated/dirs.json ${appDir}/dirs.json
            fi
            printf '%s' "$want" > "$stamp"
            ${pkgs.coreutils}/bin/chown -R ${user}:${group} ${appDir}
            # rsync preserved /nix/store's 0555/0444 modes. CWA writes runtime
            # state inside cps/ and dirs.json, so grant the owner write back.
            ${pkgs.coreutils}/bin/chmod -R u+w ${appDir}
          fi

          if [ ! -f ${configDir}/app.db ]; then
            ${pkgs.coreutils}/bin/install -m 0600 -o ${user} -g ${group} \
              ${cwa}/share/calibre-web-automated/empty_library/app.db ${configDir}/app.db
          fi

          if [ ! -f ${libraryDir}/metadata.db ]; then
            ${pkgs.coreutils}/bin/install -m 0644 -o ${user} -g ${group} \
              ${cwa}/share/calibre-web-automated/empty_library/metadata.db ${libraryDir}/metadata.db
          fi

          ${pkgs.sqlite}/bin/sqlite3 ${configDir}/app.db <<SQL
          UPDATE settings SET
            config_converterpath = '${pkgs.calibre}/bin/ebook-convert',
            config_kepubifypath  = '${pkgs.kepubify}/bin/kepubify',
            config_binariesdir   = '${pkgs.calibre}/bin',
            config_calibre_dir   = '/calibre-library';
          SQL
          # sqlite3 ran as root; reclaim db + journal/wal/shm for the user.
          for f in ${configDir}/app.db ${configDir}/app.db-journal ${configDir}/app.db-wal ${configDir}/app.db-shm; do
            [ -e "$f" ] && ${pkgs.coreutils}/bin/chown ${user}:${group} "$f" || true
          done

          # ---- preflight diagnostics (remove once green) ----
          echo "==== cwa preflight ===="
          ${pkgs.coreutils}/bin/ls -ld ${pkgs.calibre}/bin || true
          ${pkgs.coreutils}/bin/ls -l ${pkgs.calibre}/bin/ebook-convert || true
          HOME=/config QT_QPA_PLATFORM=offscreen \
            ${pkgs.calibre}/bin/ebook-convert --version 2>&1 | ${pkgs.coreutils}/bin/head -5 \
            || echo "ebook-convert --version FAILED rc=$?"
          ${pkgs.sqlite}/bin/sqlite3 ${configDir}/app.db \
            'SELECT config_binariesdir, config_converterpath, config_kepubifypath FROM settings;' \
            || echo "sqlite SELECT FAILED rc=$?"
          echo "==== end preflight ===="
        ''))
      ];
      ExecStart = "${cwa}/bin/calibre-web-automated -i ${addr}";
      Restart = "on-failure";
      RestartSec = 5;
      ReadWritePaths = [ stateDir ];
    };
  };

  # Auto-ingest watcher: polls ingest folder, hands each new file to CWA's
  # own ingest_processor.py (the same script the upstream s6 service uses).
  systemd.services.calibre-web-automated-watcher = {
    description = "Calibre-Web-Automated ingest folder watcher";
    after = [ "calibre-web-automated.service" ];
    requires = [ "calibre-web-automated.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = cwaEnv;
    path = runtimePath;

    serviceConfig = hardenedServiceConfig // bindMounts // {
      Type = "simple";
      User = user;
      Group = group;
      WorkingDirectory = "/app/calibre-web-automated";
      ExecStart = pkgs.writeShellScript "cwa-ingest-loop" ''
        set -eu
        ${cwa}/bin/cwa-watch-fallback \
          --path /cwa-book-ingest \
          --interval 5 \
          --exts epub,kepub,azw,azw3,mobi,pdf,cbz,cbr,cb7,fb2,rtf,txt,docx,doc,html,htm,lrf,lit,opf \
          | while read -r line; do
              event="''${line%% *}"
              filepath="''${line#* }"
              if [ "$event" = "CLOSE_WRITE" ] && [ -f "$filepath" ]; then
                ${cwa}/bin/cwa-ingest-processor "$filepath" || true
              fi
            done
      '';
      Restart = "on-failure";
      RestartSec = 5;
      ReadWritePaths = [ stateDir ];
    };
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://${addr}:${builtins.toString port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Port $server_port;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_max_temp_file_size 0;
          proxy_read_timeout 300s;
          proxy_buffers 16 64k;
          proxy_busy_buffers_size 128k;
        '';
      };
    };
  };
}
