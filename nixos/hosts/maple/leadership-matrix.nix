{
  inputs,
  vars,
  ...
}:
let
  port = "13121";
in
{
  imports = [ inputs.leadership-matrix.nixosModules.default ];

  services.leadership-matrix = {
    enable = true;

    # Web server bind address
    host = "127.0.0.2:${port}";

    # Run as a specific user/group
    user = "root";
    group = "root";

    workingDirectory = "/var/lib";

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
        proxyPass = "http://127.0.0.2:${port}";
        proxyWebsockets = true;
      };
    };
  };
}
