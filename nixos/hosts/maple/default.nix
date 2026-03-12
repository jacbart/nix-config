{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../security/acme-base.nix
    ../../hardware/rockpro64.nix
    ../../services/tailscale.nix
    ../../services/fail2ban.nix
    ../distributed-builds.nix
    ../../services/minio.nix
    ../../services/kiwix-serve.nix
    ../../services/postgresql.nix
    ../../services/zitadel.nix
    ../../services/nextcloud-server.nix
    ../../services/audiobooks.nix
    # ../../services/tentenmail.nix
    ../../services/dendrite.nix
    # ../../services/postmoogle.nix
    ../../services/microbin.nix
    ../../services/smartmon.nix
    ../../services/leadership-matrix.nix
  ];

  services.leadership-matrix = {
    services = lib.mkForce [
      "leadership-matrix"
      "smartd"
      "nginx"
      "tailscaled"
      "fail2ban"
      "zitadel"
      "phpfpm-nextcloud"
      "audiobookshelf"
      "dendrite"
      "kiwix"
      "postgresql"
      "minio"
      "redis-nextcloud"
    ];
    zpoolName = lib.mkForce "trunk";
  };

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

  ## ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "trunk" ];
  boot.zfs.forceImportRoot = false;

  # Limit ZFS ARC to 1GB -- with 4GB RAM and heavy services
  # (PostgreSQL, Nextcloud, Redis, MinIO, Dendrite), ZFS ARC
  # will otherwise consume too much memory and starve userspace.
  boot.kernelParams = [ "zfs.zfs_arc_max=1073741824" ];

  # zfs services
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # zfs tools
  environment.systemPackages = [ pkgs.zfs ];

  # fstab
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      priority = 0;
      size = 16 * 1024;
    }
  ];

  # zram Swap
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 100;
  };

  # ── Server sysctl tuning ───────────────────────────────────────────────
  boot.kernel.sysctl = {
    # VM / memory management (critical for 4GB RAM with heavy services)
    "vm.swappiness" = 10; # Prefer keeping pages in RAM over swapping
    "vm.dirty_ratio" = 15; # % of RAM for dirty pages before sync
    "vm.dirty_background_ratio" = 5; # Background writeback threshold
    "vm.vfs_cache_pressure" = 50; # Keep dentries/inodes cached longer
    "vm.min_free_kbytes" = 65536; # Reserve 64MB for kernel allocations

    # File descriptors (Nextcloud + PostgreSQL + Redis need many)
    "fs.file-max" = 2097152;
    "fs.inotify.max_user_watches" = 524288;

    # Network performance
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # SysRq for emergency recovery (useful for remote ARM boards)
    "kernel.sysrq" = 1;
  };

  # ── Hardware watchdog ─────────────────────────────────────────────────
  # Auto-reboot on kernel hang -- important for always-on headless server
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "10min";
  };

  networking = {
    hostId = "01d4f038";
    hosts = {
      "127.0.0.2" = [
        "maple.meep.sh"
        "auth.meep.sh"
        "books.meep.sh"
        "cloud.meep.sh"
        "minio.meep.sh"
        "s3.meep.sh"
        "wiki.meep.sh"
      ];
      "100.78.207.83" = [
        "unicron"
        "unicron.bbl.systems"
      ];
      "10.120.0.1" = [
        "mesquite"
        "mesquite.meep.sh"
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;

  nix.settings = {
    max-jobs = 3;
    cores = 6;
  };
}
