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
      # uConsole kernel: nixos-hardware rpi-6.18.y + CWU50 panel/backlight/PMU
      # drivers; also wires the firmware partition (U-Boot, config.txt).
      inputs.nixos-uconsole.nixosModules."kernel-6.18-potatomania"
      # The card is flashed by dd'ing this image; filesystems (by-label
      # NIXOS_SD/FIRMWARE) come from the sd-image module, no disko.
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ../../nixos/security/acme-hostname.nix
      config.flake.modules.nixos.profileOnlinePersonal
      (
        { pkgs, ... }:
        let
          lm = import ../../nixos/services/mk-leadership-matrix-package.nix { inherit pkgs inputs; };
        in
        {
          services.leadership-matrix.package = lm [
            "systemd"
            "zfs"
            "smart"
          ];

          sdImage.compressImage = false;

          environment.systemPackages = with pkgs; [
            uconsole-nx
          ];

          # zram first (fast), SD swapfile only as backstop.
          zramSwap.enable = true;
          swapDevices = [
            {
              device = "/var/lib/swapfile";
              size = 16 * 1024;
              priority = 5;
            }
          ];

          networking.wireless = {
            enable = lib.mkForce false;
            iwd = {
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
      ../../hosts/shared/distributed-builds.nix
    ];
  };
}
