{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.maple = {
    system = "aarch64-linux";
    username = "ratatoskr";
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/security/acme-base.nix
      ../../nixos/hardware/rockpro64.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/fail2ban.nix
      ../../nixos/services/minio.nix
      ../../nixos/services/kiwix-serve.nix
      ../../nixos/services/postgresql.nix
      ../../nixos/services/zitadel.nix
      ../../nixos/services/nextcloud-server.nix
      ../../nixos/services/books.nix
      ../../nixos/services/dendrite.nix
      ../../nixos/services/microbin.nix
      ../../nixos/services/smartmon.nix
      ../../nixos/services/leadership-matrix.nix
      ../../nixos/services/koreader-sync-server.nix
      # ../../nixos/services/attic.nix
      # ../../nixos/services/hydra.nix
      # ../../nixos/services/mailserver.nix
      # ../../nixos/services/maildns.nix
      # ../../nixos/services/nixupd-client.nix
    ]
    ++ [
      (
        { pkgs, ... }:
        {
          services.leadership-matrix = {
            package = import ../../nixos/services/leadership-matrix-package.nix {
              inherit pkgs inputs;
              cargoFeatures = [
                "aggregate"
                "systemd"
                "zfs"
                "smart"
              ];
            };
            zpoolName = lib.mkForce "trunk";
          };

          # Enable koreader sync server
          services.koreader-sync-server.enable = true;

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
          boot.kernelParams = [ "zfs.zfs_arc_max=1073741824" ];

          # zfs services
          services.zfs.autoScrub.enable = true;
          services.zfs.trim.enable = true;

          # zfs tools
          environment.systemPackages = [ pkgs.zfs ];

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
            "vm.swappiness" = 10;
            "vm.dirty_ratio" = 15;
            "vm.dirty_background_ratio" = 5;
            "vm.vfs_cache_pressure" = 50;
            "vm.min_free_kbytes" = 65536;

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
                "kosync.meep.sh"
                "mail.meep.sh"
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
                587
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
      )
    ]
    ++ [
      ./disks.nix
    ]
    ++ [
      ../../hosts/shared/distributed-builds.nix
    ];
  };
}
