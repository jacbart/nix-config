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
    virtualHosts."cnc.${vars.domain}" = {
      addSSL = true;
      useACMEHost = vars.domain;
      locations."/" = {
        proxyPass = "https://127.0.0.1:13000";
      };
    };
  };
}
