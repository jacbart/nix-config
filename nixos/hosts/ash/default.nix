{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../hardware/uconsole.nix
    ./remote-builder.nix
    ../../services/tailscale.nix
  ];

  environment.systemPackages = [
    pkgs.uconsole-nx
    # (pkgs.retroarch.override {
    #   cores = [
    #     pkgs.libretro.mgba
    #   ];
    # })
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "x-initrd"
      ];
    };
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  networking = {
    hosts = {
      "127.0.0.2" = [ "ash.meep.sh" ];
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
    wireless.iwd = {
      enable = lib.mkDefault true;
      settings = {
        Network = {
          EnableIPv6 = lib.mkDefault true;
          RoutePriorityOffset = lib.mkDefault 300;
        };
        Settings = {
          AutoConnect = lib.mkDefault true;
        };
      };
    };
  };
}
