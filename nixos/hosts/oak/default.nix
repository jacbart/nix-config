{ modulesPath
, lib
, ...
}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-image.nix")
    ../../apps/ghostty.nix # enable xterm-ghostty
    ../../services/fail2ban.nix
    ../../services/tailscale.nix
  ];

  virtualisation.digitalOceanImage.compressionMethod = "bzip2";
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  services.openssh = {
    ports = [ 3048 ];
    settings.PasswordAuthentication = lib.mkForce false;
    settings.PermitRootLogin = lib.mkForce "yes";
  };
  time.timeZone = lib.mkForce "Europe/Berlin";

  swapDevices = [{
    device = "/swap/swapfile";
    size = 1024 * 2; # 2GB
  }];
}
