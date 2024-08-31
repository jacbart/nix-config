{ config, pkgs, ... }: {
    sops.secrets = {
      minio-creds = {
        owner = "minio";
        group = "minio";
      };
    };
    
    services.minio = {
      enable = true;
      package = pkgs.minio;
      region = "us-az-phx";
      browser = true;
      consoleAddress = ":9001";
      listenAddress = ":9000";
      rootCredentialsFile = config.sops.secrets.minio-creds.path;
      configDir = "/var/lib/minio/config";
      dataDir = [
        "/var/lib/minio/data"
      ];
    };

    environment.systemPackages = [ pkgs.minio-client ];
}
