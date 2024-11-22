# This configuration file can be safely imported in your system configuration.
{ lib, ... }: {
  boot.initrd.availableKernelModules = [ "ahci" "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
