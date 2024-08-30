{ pkgs, ... }: {
    services.minio = {
      enable = true;
      package = pkgs.minio;
      region = "us-az-phx";
      browser = true;
      consoleAddress = ":9001";
      listenAddress = ":9000";
      rootCredentialsFile = "/etc/nixos/minio-root-credentials";
      configDir = "/var/lib/minio/config";
      dataDir = [
        "/var/lib/minio/data"
      ];
    };
}
