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
    ../../apps/ghostty.nix # enable xterm-ghostty
    ../../services/minio.nix
    # ../../services/mobilizon.nix
    ../../services/kiwix-serve.nix
    ../../services/postgresql.nix
    ../../services/zitadel.nix
    ../../services/nextcloud-server.nix
    ../../services/audiobooks.nix
    ../../services/dendrite.nix
    # ../../services/postmoogle.nix
    ../../services/smartmon.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
  ## ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "trunk" ];
  boot.zfs.forceImportRoot = false;

  # zfs services
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # zfs tools
  environment.systemPackages = [ pkgs.zfs ];

  # fstab
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
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
    priority = 10;
    memoryPercent = 100;
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
      # "192.168.1.1" = [ "mesquite" "mesquite.meep.sh" ];
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
