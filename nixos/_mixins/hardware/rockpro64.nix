# This configuration file can be safely imported in your system configuration.
{ pkgs, lib, ... }:

{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # This list of modules is not entirely minified, but represents
  # a set of modules that is required for the display to work in stage-1.
  # Further minification can be done, but requires trial-and-error mainly.
  boot.initrd.availableKernelModules = [ "ahci" "usb_storage" "usbhid" ];
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"
  ];

  fileSystems."/" = {
    device = "/dev/dis/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  networking.useDHCP = lib.mkDefault true;
  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
