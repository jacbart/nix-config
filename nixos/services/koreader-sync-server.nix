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
        default = 6379; # TCP port for Redis (upstream db/redis.lua expects 127.0.0.1:6379)
        description = "Redis port (6379 for TCP, 0 for Unix socket only).";
      };

      unixSocket = lib.mkOption {
        type = lib.types.str;
        default = "/run/redis-kosync/redis.sock";
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

    # Data directories - use 0755 so kosync can access even with group quirks
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} -"
      "d ${dataDir}/logs 0755 ${user} ${group} -"
      "d ${dataDir}/app 0755 ${user} ${group} -"
      "d ${dataDir}/config 0755 ${user} ${group} -"
      "d ${dataDir}/tmp 0755 ${user} ${group} -"
    ]
    ++ lib.optional cfg.redis.enable "d ${redisDataDir} 0755 ${user} ${group} -"
    ++ lib.optional cfg.redis.enable "d /run/redis-kosync 0755 ${user} ${group} -";

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
            ${pkgs.coreutils}/bin/mkdir -p ${dataDir}/{logs,app,config,tmp}
            ${pkgs.coreutils}/bin/chown -R ${user}:${group} ${dataDir}
            # Make directories accessible (755 for dirs, 644 for files)
            ${pkgs.coreutils}/bin/chmod -R u+rwX,go+rX ${dataDir}

            # Copy app files if not present
            if [ ! -f ${dataDir}/app/main.lua ]; then
              ${pkgs.coreutils}/bin/cp -r ${cfg.package}/share/koreader-sync-server/app/* ${dataDir}/app/ 2>/dev/null || true
              ${pkgs.coreutils}/bin/cp -r ${cfg.package}/share/koreader-sync-server/lib/* ${dataDir}/app/ 2>/dev/null || true
              ${pkgs.coreutils}/bin/cp -r ${cfg.package}/share/koreader-sync-server/config/* ${dataDir}/config/ 2>/dev/null || true
              ${pkgs.coreutils}/bin/cp -r ${cfg.package}/share/koreader-sync-server/db/* ${dataDir}/db/ 2>/dev/null || true
              ${pkgs.coreutils}/bin/chown -R ${user}:${group} ${dataDir}
              ${pkgs.coreutils}/bin/chmod -R u+rwX,go+rX ${dataDir}
            fi

            # Generate proper nginx.conf with gin framework initialization
            cat > ${dataDir}/config/nginx.conf << 'EOF'
            pid ${dataDir}/tmp/production-nginx.pid;
            daemon off;
            error_log ${dataDir}/logs/production-error.log debug;

            env ENABLE_USER_REGISTRATION;
            env GIN_ENV;

            worker_processes 4;

            events {
                worker_connections 4096;
            }

            http {
                lua_package_path "${dataDir}/?.lua;${dataDir}/?/init.lua;${dataDir}/app/?.lua;${dataDir}/app/?/init.lua;${cfg.package}/share/koreader-sync-server/lib/?.lua;${cfg.package}/share/koreader-sync-server/lib/?/init.lua;${cfg.package}/share/koreader-sync-server/lib/redis-lua/?.lua;${cfg.package.luajitWithPackages}/share/lua/5.1/?.lua;${cfg.package.luajitWithPackages}/share/lua/5.1/?/init.lua;;";
                lua_package_cpath "${dataDir}/lib/?.so;${cfg.package}/lib/?.so;${cfg.package.luajitWithPackages}/lib/lua/5.1/?.so;;";
                
                # Gin initialization
                init_by_lua_block {
                    require "gin.core.gin"
                }
                
                # Access log with buffer
                access_log ${dataDir}/logs/production-access.log combined buffer=16k;
                
                server {
                    listen ${toString cfg.port};
                    
                    location / {
                        content_by_lua_block {
                            require("gin.core.router").handler(ngx)
                        }
                    }
                }
            }
            EOF

            ${pkgs.coreutils}/bin/chown ${user}:${group} ${dataDir}/config/nginx.conf
            ${pkgs.coreutils}/bin/chmod 644 ${dataDir}/config/nginx.conf
          ''}
        '';

        ExecStart = ''
          ${cfg.package}/bin/openresty -p ${dataDir} -c config/nginx.conf -e ${dataDir}/logs/error.log
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
