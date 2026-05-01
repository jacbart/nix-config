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

  # rustfs-flake unit is over-hardened vs upstream static musl+aarch64 RustFS: still hit EACCES after credentials
  # (mmap/sockets/volume IO — exact syscall depends on build). Relax to a normal long-running network daemon.
  systemd.services.rustfs.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    PrivateDevices = lib.mkForce false;
    DevicePolicy = lib.mkForce "auto";
    ProtectSystem = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    ProtectKernelLogs = lib.mkForce false;
    ProtectKernelModules = lib.mkForce false;
    ProtectKernelTunables = lib.mkForce false;
    ProtectClock = lib.mkForce false;
    ProtectControlGroups = lib.mkForce false;
    ProtectHostname = lib.mkForce false;
    ProtectProc = lib.mkForce "no";
    ProcSubset = lib.mkForce "all";
    RestrictNamespaces = lib.mkForce false;
    RestrictRealtime = lib.mkForce false;
    RestrictSUIDSGID = lib.mkForce false;
    LockPersonality = lib.mkForce false;
    SystemCallFilter = lib.mkForce "@known";
    UMask = lib.mkForce "0027";
    RestrictAddressFamilies = lib.mkForce [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
  };

  # If the tree was ever root-owned (ZFS hand moves, manual tar, etc.), normalize for the rustfs account.
  systemd.tmpfiles.rules = [
    "Z /var/lib/rustfs 0750 rustfs rustfs - -"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."s3.${domain}" = {
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9000";
        proxyWebsockets = true;
        # Preserve public Host; default with IP proxy_pass is Host=127.0.0.1 → SigV4 mismatch / fake "bad creds".
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_ssl_server_name on;
          proxy_pass_header Authorization;
        '';
      };
    };
    virtualHosts."fs.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9001";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_ssl_server_name on;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
}
