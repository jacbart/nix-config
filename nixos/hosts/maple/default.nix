{ pkgs
, lib
, ...
}: {
  imports = [
    ../../hardware/rockpro64.nix
    ../../services/tailscale.nix
    # ../../services/fail2ban.nix
    ./distributed-builds.nix
    ../../apps/ghostty.nix # enable xterm-ghostty
    ../../services/minio.nix
    ../../services/kiwix-serve.nix
    ../../services/postgresql.nix
    ../../services/zitadel.nix
    ../../services/nextcloud-server.nix
    ../../services/audiobooks.nix
    ../../services/smartmon.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  ## ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.zfs.extraPools = [ "trunk" ];
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  environment.systemPackages = [ pkgs.zfs ];

  # Fstab
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  networking = {
    hostId = "01d4f038";
    hosts = {
      "127.0.0.1" = [ "maple" "maple.meep.sh" ];
      "192.168.1.1" = [ "mesquite" "mesquite.meep.sh" ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 3000 9000 9001 ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;

  nix.settings = {
    max-jobs = 3;
    cores = 6;
  };
}
