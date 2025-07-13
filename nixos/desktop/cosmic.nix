{ pkgs, ... }: {
  services = {
    desktopManager.cosmic = {
      enable = true;
      xwayland.enable = true;
    };
    displayManager.cosmic-greeter = {
      enable = true;
      package = pkgs.cosmic-greeter;
    };
  };

  environment.systemPackages = [
    pkgs.power-profiles-daemon
  ];
}
