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

  # rustfs-flake hardening fights upstream prebuilt aarch64 musl (mimalloc) + workload:
  # - MemoryDenyWriteExecute can break allocator-style mappings.
  # - SystemCallFilter includes "~@resources" which blocks mmap-family syscalls after early bootstrap → Permission denied.
  # - PrivateUsers occasionally breaks credential/volume paths on constrained hosts.
  systemd.services.rustfs.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    SystemCallFilter = lib.mkForce [
      "@system-service"
      "~@privileged"
    ];
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
