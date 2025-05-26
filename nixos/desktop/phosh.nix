{ pkgs, ... }: {
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "meep";
    group = "users";
    phocConfig.xwayland = "immediate";
  };
  environment.systemPackages = [
    pkgs.power-profiles-daemon
  ];
}
