{ desktop, lib, pkgs, ... }: {
  imports = [
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}-apps.nix")) ./${desktop}-apps.nix;

  # boot = {
  #   kernelParams = [ "loglevel=4" ];
  #   plymouth.enable = true;
  # };

  hardware = {
    opengl = {
      enable = true;
      # driSupport = true;
    };
  };

  # programs.dconf.enable = true;

  # Disable xterm
  # services.xserver.excludePackages = [ pkgs.xterm ];
  # services.xserver.desktopManager.xterm.enable = false;

  # systemd.services.disable-wifi-powersave = {
  #   wantedBy = ["multi-user.target"];
  #   path = [ pkgs.iw ];
  #   script = ''
  #     iw dev wlan0 set power_save off
  #   '';
  # };

  # xdg.portal = {
  #   enable = true;
  #   xdgOpenUsePortal = true;
  # };
}
