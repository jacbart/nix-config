{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  # CM4/Pi firmware chain-loads kernels via extlinux; there is no BIOS disk for GRUB.
  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "snd_bcm2835.enable_compat_alsa=0"
    "snd_bcm2835.enable_headphones=1"
    "snd_bcm2835.enable_hdmi=1"
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];

  #rotate screen
  # services.xserver = {
  #   resolutions = [
  #     {
  #       x = 720;
  #       y = 1280;
  #     }
  #   ];
  #   xrandrHeads = [
  #     {
  #       output = "DSI-1";
  #       monitorConfig = "Option \"Rotate\" \"right\"";
  #       primary = true;
  #     }
  #   ];
  # };

  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  nixpkgs.overlays = [
    outputs.overlays.uconsole-mods
  ];
}
