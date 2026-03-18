{
  config,
  lib,
  pkgs,
  vars,
  ...
}:

let
  cfg = config.services.koreader-sync-server;

  subdomain = "kosync";
  domain = vars.domain;

  user = "kosync";
  group = "kosync";
  dataDir = "/var/lib/koreader-sync-server";
  redisDataDir = "${dataDir}/redis";

  package =
    pkgs.koreader-sync-server or pkgs.unstable.koreader-sync-server
      or (pkgs.callPackage ../../pkgs/koreader-sync-server { });
in
{
  options.services.koreader-sync-server = {
    enable = lib.mkEnableOption "KOReader sync server - self-hostable synchronization service for KOReader devices";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "The KOReader sync server package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 17200;
      description = "Port to listen on (HTTP, behind reverse proxy).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.2";
      description = "Host address to bind to.";
    };

    enableUserRegistration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable user registration.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables to pass to the service.";
    };

    redis = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable a dedicated Redis instance for KOReader sync server.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 0; # Unix socket only
        description = "Redis port (0 for Unix socket only).";
      };

      unixSocket = lib.mkOption {
        type = lib.types.str;
        default = "${dataDir}/redis/redis.sock";
        description = "Path to Redis Unix socket.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create system user and group
    users.users.${user} = {
      isSystemUser = true;
      inherit group;
      home = dataDir;
      description = "KOReader Sync Server user";
    };

    users.groups.${group} = { };

    # Data directories
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 ${user} ${group} -"
      "d ${dataDir}/logs 0750 ${user} ${group} -"
      "d ${dataDir}/app 0750 ${user} ${group} -"
    ]
    ++ lib.optional cfg.redis.enable "d ${redisDataDir} 0750 ${user} ${group} -";

    # Redis service (dedicated instance)
    services.redis.servers.kosync = lib.mkIf cfg.redis.enable {
      enable = true;
      inherit user group;
      port = cfg.redis.port;
      unixSocket = cfg.redis.unixSocket;
      unixSocketPerm = 770;
      settings = {
        dir = lib.mkForce redisDataDir;
        maxmemory = "256mb";
        maxmemory-policy = "allkeys-lru";
        save = [
          "900 1"
          "300 10"
          "60 10000"
        ];
      };
    };

    # KOReader sync server service
    systemd.services.koreader-sync-server = {
      description = "KOReader Sync Server - synchronization service for KOReader devices";
      after = [ "network.target" ] ++ lib.optional cfg.redis.enable "redis-kosync.service";
      wants = lib.optional cfg.redis.enable "redis-kosync.service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;

        WorkingDirectory = dataDir;
        StateDirectory = "koreader-sync-server";

        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") (
          {
            GIN_ENV = "production";
            ENABLE_USER_REGISTRATION = lib.boolToString cfg.enableUserRegistration;
            KOSYNC_PORT = toString cfg.port;
            KOSYNC_HOST = cfg.host;
          }
          // cfg.environment
        );

        ExecStartPre = ''
          +${pkgs.writeShellScript "koreader-sync-server-setup" ''
            # Create data directory structure as root
            ${pkgs.coreutils}/bin/mkdir -p ${dataDir}/{logs,app}
            ${pkgs.coreutils}/bin/chown -R ${user}:${group} ${dataDir}

            # Copy app files if not present
            if [ ! -f ${dataDir}/app/main.lua ]; then
              ${pkgs.coreutils}/bin/cp -r ${cfg.package}/share/koreader-sync-server/app/* ${dataDir}/app/
              ${pkgs.coreutils}/bin/chown -R ${user}:${group} ${dataDir}/app
            fi
          ''}
        '';

        ExecStart = ''
          ${cfg.package}/bin/koreader-sync-server
        '';

        ExecStop = ''
          ${pkgs.coreutils}/bin/kill -QUIT $MAINPID
        '';

        ExecReload = ''
          ${pkgs.coreutils}/bin/kill -HUP $MAINPID
        '';

        Restart = "on-failure";
        RestartSec = "5s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ dataDir ];

        # Resource limits
        LimitNOFILE = 65536;
        LimitNPROC = 512;
      };

      preStart = ''
        # Update nginx config with correct settings
        if [ -f ${dataDir}/app/config/nginx.conf ]; then
          # Add daemon off if not present
          ${pkgs.gnugrep}/bin/grep -q 'daemon off;' ${dataDir}/app/config/nginx.conf || \
            ${pkgs.coreutils}/bin/echo 'daemon off;' >> ${dataDir}/app/config/nginx.conf
        fi
      '';
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      virtualHosts."${subdomain}.${domain}" = {
        addSSL = true;
        useACMEHost = domain;
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = lib.mkIf config.networking.firewall.enable [
      443
      80
    ];
  };
}
