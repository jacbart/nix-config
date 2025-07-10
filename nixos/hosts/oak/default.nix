{ modulesPath
, lib
, ...
}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-image.nix")
    ../../security/acme-proxy.nix
    ../../apps/ghostty.nix # enable xterm-ghostty
    ../../services/fail2ban.nix
    ../../services/tailscale.nix
    ./nginx.nix
  ];

  virtualisation.digitalOceanImage.compressionMethod = "bzip2";
  networking = {
    # hostId = "";
    hosts = {
      "127.0.0.2" = [
        "oak.meep.sh"
        "matrix.meep.sh"
        "mx.meep.sh"
        "tun.meep.sh"
      ];
      "100.116.178.48" = [
        "maple.meep.sh"
        "s3.meep.sh"
        "books.meep.sh"
        "auth.meep.sh"
        "minio.meep.sh"
        "cloud.meep.sh"
        "wiki.meep.sh"
      ];
    };
    networkmanager.dns = "none";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ ];
    };
  };

  services.openssh = {
    ports = [ 3048 ];
    settings.PasswordAuthentication = lib.mkForce false;
    settings.PermitRootLogin = lib.mkForce "yes";
  };
  time.timeZone = lib.mkForce "Europe/Berlin";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024 * 2; # 2GB
    }
  ];
}
