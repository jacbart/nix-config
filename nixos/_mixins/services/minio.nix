{ config, pkgs, ... }: {
    sops.secrets = {
      minio_secret_key = {
        owner = config.services.minio.user;
        group = config.services.minio.group;
      };
    };
    
    services.minio = {
      enable = true;
      package = pkgs.minio;
      region = "us-az-phx";
      browser = true;
      consoleAddress = ":9001";
      listenAddress = ":9000";
      accessKey = "minio";
      secretKey = builtins.readFile config.sops.secrets.minio_secret_key.path;
      rootCredentialsFile = config.sops.secrets.minio_secret_key.path;
      configDir = "/var/lib/minio/config";
      dataDir = [
        "/var/lib/minio/data"
      ];
    };

    environment.systemPackages = [ pkgs.minio-client ];
}
