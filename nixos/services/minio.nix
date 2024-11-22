{ config
, pkgs
, ...
}: {
  imports = [ ./minio-client.nix ];

  sops.secrets."minio/root/access-key" = { };
  sops.secrets."minio/root/secret-key" = { };
  sops.templates."minio-root-creds" = {
    owner = "minio";
    content = ''
      MINIO_ROOT_USER="${config.sops.placeholder."minio/root/access-key"}"
      MINIO_ROOT_PASSWORD="${config.sops.placeholder."minio/root/secret-key"}"
    '';
    path = "/etc/nixos/minio-root-creds";
  };

  services.minio = {
    enable = true;
    package = pkgs.unstable.minio;
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
