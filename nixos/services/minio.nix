{
  config,
  pkgs,
  ...
}:
let
  domain = "meep.sh";
in
{
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
    consoleAddress = "127.0.0.2:9001";
    listenAddress = "127.0.0.2:9000";
    rootCredentialsFile = config.sops.templates."minio-root-creds".path;
    configDir = "/var/lib/minio/config";
    dataDir = [
      "/var/lib/minio/data"
    ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."s3.${domain}" = {
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:9000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
    virtualHosts."minio.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:9001";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
  };
}
