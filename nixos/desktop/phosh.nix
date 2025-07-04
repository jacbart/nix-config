_: {
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "meep";
    group = "users";
    phocConfig.xwayland = "immediate";
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "meep";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
