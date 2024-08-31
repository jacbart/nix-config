{ config, pkgs, ... }: {
    imports = [ ./minio-client.nix ];

    sops.secrets."minio/root/access-key" = {};
    sops.secrets."minio/root/secret-key" = {};
    sops.templates."minio-root-creds" = {
      content = ''
      MINIO_ROOT_USER="${config.sops.placeholder."minio/root/access-key"}"
      MINIO_ROOT_PASSWORD="${config.sops.placeholder."minio/root/secret-key"}"
      '';
      path = "%r/minio-root-creds";
    };
    
    services.minio = {
      enable = true;
      package = pkgs.minio;
      region = "us-az-phx";
      browser = true;
      consoleAddress = ":9001";
      listenAddress = ":9000";
      rootCredentialsFile = config.sops.templates."minio-root-creds".path;
      configDir = "/var/lib/minio/config";
      dataDir = [
        "/var/lib/minio/data"
      ];
    };
}
