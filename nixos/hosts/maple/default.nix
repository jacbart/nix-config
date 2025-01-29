{ pkgs
, lib
, ...
}: {
  imports = [
    ../../hardware/rockpro64.nix
    ../../services/fail2ban.nix
    # ./nginx.nix
    ./distributed-builds.nix
    # (import ./disks.nix { })
    ../../apps/ghostty.nix # enable xterm_ghostty when ssh from the app
    ../../services/minio.nix
    ../../services/postgresql.nix
    ../../services/zitadel.nix
    # ../../services/headscale.nix
    ../../services/nextcloud-server.nix
    ../../services/audiobooks.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  # zfs
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.zfs.extraPools = [ "trunk" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  boot.zfs.forceImportRoot = false;

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
      allowedTCPPorts = [ 80 3000 9000 9001 ];
    };
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;
}
