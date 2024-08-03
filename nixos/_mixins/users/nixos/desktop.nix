{ config, desktop, lib, pkgs, username, ... }: {
  config.environment.systemPackages = with pkgs; [
    gparted
  ];
  config.systemd.tmpfiles.rules = [
    "d /home/${username}/Desktop 0755 ${username} users"
  ];
  config.isoImage.edition = lib.mkForce "${desktop}";
  config.services.displayManager.autoLogin.user = "${username}";
  config.services.kmscon.autologinUser = lib.mkForce null;
}