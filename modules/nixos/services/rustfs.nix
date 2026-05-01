{
  config,
  lib,
  pkgs,
  vars,
  inputs,
  platform,
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
    package = inputs.rustfs.packages.${platform}.default;
    volumes = "/var/lib/rustfs";
    # RustFS rejects addresses not listed on local interfaces (rustfs_utils::net::check_local_server_addr).
    # 127.0.0.2 is rarely on lo — only 127.0.0.1 is — so bind 127.0.0.1.
    address = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    accessKeyFile = config.sops.secrets."minio/root/access-key".path;
    secretKeyFile = config.sops.secrets."minio/root/secret-key".path;
  };

  # rustfs-flake hardens RustFS like a generic Unix daemon. Prebuilt aarch64/linux is musl + mimalloc
  # (jemalloc only on x86_64-gnu); systemd MemoryDenyWriteExecute breaks that allocator → EACCES and instant exit.
  systemd.services.rustfs.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
  };

  services.nginx = {
    enable = true;
    virtualHosts."s3.${domain}" = {
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9000";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
      };
    };
    virtualHosts."fs.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9001";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
      };
    };
  };
}
