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

  # Kernel comes from the nixos-uconsole kernel-* module (nixos-hardware rpi
  # kernel + uConsole patches); do not set boot.kernelPackages here.

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

  # 4G/LTE extension (SIM7600G-H on USB). Kernel drivers (option, qmi_wwan)
  # ship with the 6.18 kernel variant; userspace is ModemManager +
  # NetworkManager (nmcli c add type gsm ...).
  networking.modemmanager.enable = lib.mkDefault true;

  # The 4G extension is powered down by default; power it on at boot.
  # Port of clockworkpi's uconsole-4g-cm4 script (Code/scripts in the
  # uConsole repo). NOTE: the original uses wiringPi pin numbers, so
  # wPi24 -> BCM19 (4G power enable) and wPi15 -> BCM14 (power key pulse).
  # Verify with `mmcli -L` that a SIMCOM_SIM7600G-H shows up.
  systemd.services.uconsole-4g-enable = {
    description = "Power on the uConsole 4G/LTE extension";
    wantedBy = [ "multi-user.target" ];
    before = [ "ModemManager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.libraspberrypi}/bin/raspi-gpio set 19 op dh
      ${pkgs.libraspberrypi}/bin/raspi-gpio set 14 op dh
      sleep 5
      ${pkgs.libraspberrypi}/bin/raspi-gpio set 14 op dl
      echo "waiting for modem to enumerate..."
      sleep 13
    '';
  };

  nixpkgs.overlays = [
    outputs.overlays.uconsole-mods
  ];
}
