{ inputs, lib, ... }:
{
  imports = [
    ../_mixins/hardware/rockpro64.nix
    # (import ./disks.nix { })
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "maple";
  # Pick only one of the below networking options.
  #networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;
}
