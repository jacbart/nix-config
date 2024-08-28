{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../_mixins/hardware/rockpro64.nix
    # (import ./disks.nix { })
    ../_mixins/services/binary-cache.nix
    ../_mixins/services/nextcloud-server.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostId = "01d4f038";
    hosts = {
      "127.0.0.1" = [ "maple" "maple.meep.sh" "cache" "cache.meep.sh" ];
      "192.168.1.1" = [ "mesquite" "mesquite.meep.sh" ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;
}
