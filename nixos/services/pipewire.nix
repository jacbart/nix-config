{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];
  # hardware = {
  #   pulseaudio.enable = lib.mkForce false;
  # };
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };
  };
}
