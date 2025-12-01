_: {
  services.displayManager.gdm.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "meep";
    group = "users";
    phocConfig.xwayland = "immediate";
    phocConfig.outputs = {
      DSI-1 = {
        rotate = "90";
        scale = 1;
      };
    };
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "meep";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
