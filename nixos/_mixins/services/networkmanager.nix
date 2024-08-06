{ pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [ "192.168.1.1" "1.1.1.1" "9.9.9.9" ];
      wifi = {
        backend = "iwd";
        powersave = false;
      };
    };
    wireless.iwd.package = pkgs.unstable.iwd;
  };
  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
