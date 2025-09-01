{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../hardware/uconsole.nix
    ../distributed-builds.nix
    # ./remote-builder.nix
    ../../services/tailscale.nix
  ];

  # use x86_64 steam and allow unfree license
  nixpkgs.overlays = [
    (
      self: super:
      let
        x86pkgs = import pkgs.path {
          system = "x86_64-linux";
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "steam"
              "steam-original"
              "steam-runtime"
              "steam-unwrapped"
            ];
        };
      in
      {
        inherit (x86pkgs) steam steam-run;
      }
    )
  ];

  environment.systemPackages = with pkgs; [
    uconsole-nx
    steam
    steam-run
    # (pkgs.retroarch.override {
    #   cores = [
    #     pkgs.libretro.mgba
    #   ];
    # })
  ];

  # allow build for x86_64-linux architecture through emulation
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

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
