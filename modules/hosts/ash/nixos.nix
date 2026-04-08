{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.ash = {
    system = "aarch64-linux";
    username = "meep";
    desktop = "phosh";
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/hardware/uconsole.nix
      ../../nixos/security/acme-hostname.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/leadership-matrix.nix
      ../../nixos/services/nixupd-client.nix
    ]
    ++ [
      (
        { pkgs, ... }:
        {
          services.leadership-matrix = {
            package = import ../../nixos/services/leadership-matrix-package.nix {
              inherit pkgs inputs;
              cargoFeatures = [ "systemd" ];
            };
          };

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
      )
    ]
    ++ [
      ./disks.nix
      # ./remote-builder.nix
    ]
    ++ [
      ../../hosts/shared/distributed-builds.nix
    ];
  };
}
