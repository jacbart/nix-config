# This configuration file can be safely imported in your system configuration.
{ config, pkgs, lib, ... }:

{

  boot.initrd.availableKernelModules = [ "ahci" "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.zfs.extraPools = [ "trunk" ];
  services.zfs.autoScrub.enable = true;
  boot.zfs.forceImportRoot = false;
  services.zfs.trim.enable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  networking.useDHCP = lib.mkDefault true;
  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
