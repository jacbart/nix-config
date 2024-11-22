# This configuration file can be safely imported in your system configuration.
{ pkgs
, lib
, outputs
, ...
}: {
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "snd_bcm2835.enable_compat_alsa=0"
    "snd_bcm2835.enable_headphones=1"
    "snd_bcm2835.enable_hdmi=1"
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];

  #rotate screen
  services.xserver = {
    resolutions = [
      {
        x = 720;
        y = 1280;
      }
    ];
    xrandrHeads = [
      {
        monitorConfig = ''Option "Rotate" "right"'';
        output = "DSI-1";
      }
    ];
  };

  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  nixpkgs.overlays = [
    outputs.overlays.uconsole-mods
  ];
}
