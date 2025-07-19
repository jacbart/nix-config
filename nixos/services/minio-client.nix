{
  config,
  pkgs,
  username,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  systemd.tmpfiles.rules = [
    "d ${homeDir}/.mc 0755 ${username}"
    "d ${homeDir}/.mc/share 0755 ${username}"
  ];

  sops.secrets."minio/root/access-key" = { };
  sops.secrets."minio/root/secret-key" = { };
  sops.secrets."minio/nixbuilder/access-key" = { };
  sops.secrets."minio/nixbuilder/secret-key" = { };
  sops.secrets."minio/nixbuilder/region" = { };

  sops.templates."dot-mc-config.json" = {
    owner = username;
    content = ''
      {
        "version": "10",
        "aliases": {
          "s3": {
            "url": "https://s3.meep.sh",
            "accessKey": "${config.sops.placeholder."minio/root/access-key"}",
            "secretKey": "${config.sops.placeholder."minio/root/secret-key"}",
            "api": "s3v4",
            "path": "auto"
          }
        }
      }
    '';
    path = "${homeDir}/.mc/config.json";
  };

  sops.templates."mc-boto-creds" = {
    owner = username;
    content = ''
      [nixbuilder]
      aws_access_key_id=${config.sops.placeholder."minio/nixbuilder/access-key"}
      aws_secret_access_key=${config.sops.placeholder."minio/nixbuilder/secret-key"}
    '';
    path = "${homeDir}/.aws/credentials";
  };

  sops.templates."mc-boto-conf" = {
    owner = username;
    content = ''
      [profile nixbuilder]
      region=${config.sops.placeholder."minio/nixbuilder/region"}
    '';
    path = "${homeDir}/.aws/config";
  };

  environment.systemPackages = [ pkgs.minio-client ];
}
