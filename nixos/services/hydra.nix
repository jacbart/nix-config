{ config
, pkgs
, ...
}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/hydra/.aws 0644 hydra hydra"
    "f /etc/nixos/secret.key 0644 hydra"
  ];

  services.hydra = {
    enable = true;
    package = pkgs.unstable.hydra;
    hydraURL = "https://hydra.meep.sh";
    notificationSender = "ratatoskr@meep.sh";
    extraConfig = ''
      store_uri = s3://nix-cache?&endpoint=s3.meep.sh&compression=zstd&parallel-compression=true&write-nar-listing=1&ls-compression=br&log-compression=br&secret-key=/etc/nixos/secret.key&trusted=true
      upload_logs_to_binary_cache = true
    '';
    useSubstitutes = true;
  };

  #### user already created, idk if this would break that
  # users.users.hydra = {
  #   isNormalUser = true;
  #   createHome = false;
  #   group = "hydra";
  # };

  # users.groups.hydra = {};

  nix.settings.trusted-users = [ "hydra" "remotebuild" ];

  sops.secrets."minio/nixbuilder/access-key" = { };
  sops.secrets."minio/nixbuilder/secret-key" = { };
  sops.secrets."minio/nixbuilder/region" = { };

  sops.templates."hydra-boto-creds" = {
    owner = "hydra";
    content = ''
      [default]
      aws_access_key_id=${config.sops.placeholder."minio/nixbuilder/access-key"}
      aws_secret_access_key=${config.sops.placeholder."minio/nixbuilder/secret-key"}
    '';
    path = "/var/lib/hydra/.aws/credentials";
  };

  sops.templates."hydra-boto-conf" = {
    owner = "hydra";
    content = ''
      [profile default]
      region=${config.sops.placeholder."minio/nixbuilder/region"}
    '';
    path = "/var/lib/hydra/.aws/config";
  };

  # environment.systemPackages = with pkgs; [ hydra-cli ];
}
