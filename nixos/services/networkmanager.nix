{ pkgs, ... }: {
  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [ "192.168.0.120" "1.1.1.1" "1.0.0.1" ];
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
