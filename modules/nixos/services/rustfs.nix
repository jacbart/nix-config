{
  config,
  pkgs,
  vars,
  inputs,
  ...
}:
let
  domain = vars.domain;
in
{
  imports = [
    inputs.rustfs.nixosModules.rustfs
    ./s3-client.nix
  ];

  sops.secrets."minio/root/access-key" = { };
  sops.secrets."minio/root/secret-key" = { };

  services.rustfs = {
    enable = true;
    package = inputs.rustfs.packages.${pkgs.stdenv.hostPlatform.system}.default;
    volumes = "/var/lib/rustfs";
    address = "127.0.0.2:9000";
    consoleAddress = "127.0.0.2:9001";
    accessKeyFile = config.sops.secrets."minio/root/access-key".path;
    secretKeyFile = config.sops.secrets."minio/root/secret-key".path;
  };

  services.nginx = {
    enable = true;
    virtualHosts."s3.${domain}" = {
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:9000";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
      };
    };
    virtualHosts."fs.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:9001";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
      };
    };
  };
}
