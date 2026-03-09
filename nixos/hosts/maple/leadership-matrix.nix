{ inputs, vars, ... }:
{

  imports = [ inputs.leadership-matrix.nixosModules.default ];

  services.leadership-matrix = {
    enable = true;

    # Web server bind address
    host = "127.0.0.2:13000";

    # Run as a specific user/group
    user = "root";
    group = "root";

    # ZFS pool to monitor (omit to disable ZFS pool monitoring)
    zpoolName = "trunk";

    # Systemd services to monitor
    services = [
      "smartd"
      "nginx"
      "tailscaled"
      "fail2ban"
      "zitadel"
      "phpfpm-nextcloud"
      "audiobookshelf"
      "dendrite"
      "kiwix"
      "postgresql"
      "minio"
      "redis-nextcloud"
    ];

    # NVIDIA GPU monitoring (requires nvidia feature in the package)
    nvidia = {
      enable = true;
      # nvmlPath = "/usr/lib/libnvidia-ml.so.1";  # custom path if needed
    };

    # Additional environment variables
    extraEnv = {
      RUST_LOG = "info";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."console.${vars.domain}" = {
      useACMEHost = vars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:13000";
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
