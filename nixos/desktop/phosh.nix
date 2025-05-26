{ pkgs, ... }: {
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
