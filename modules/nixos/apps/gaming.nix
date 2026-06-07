{ pkgs, ... }:
{
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0; # AMD desktop — skip iGPU energy errors
  };

  hardware.graphics.enable32Bit = true;

  programs.steam = {
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    extraPackages = with pkgs; [
      gamescope
      mangohud
      libkrb5
      libusb1
    ];
  };

  boot.kernel.sysctl."vm.swappiness" = 10; # prefer RAM; disk swap only under pressure
}
