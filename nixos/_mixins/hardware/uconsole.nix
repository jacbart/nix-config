# This configuration file can be safely imported in your system configuration.
{ pkgs, lib, ... }:

{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "snd_bcm2835.enable_compat_alsa=0"
    "snd_bcm2835.enable_headphones=1"
    "snd_bcm2835.enable_hdmi=1"
  ];

  # This list of modules is not entirely minified, but represents
  # a set of modules that is required for the display to work in stage-1.
  # Further minification can be done, but requires trial-and-error mainly.
  boot.initrd.availableKernelModules = [  ];
  boot.initrd.kernelModules = [
    # uConsole modules

  ];

  services.xserver.xrandrHeads = [
    { monitorConfig = ''Option "Rotate" "right"''; output = "DSI-1"; }
  ];

  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;
  powerManagement.cpuFreqGovernor = "ondemand";
}
