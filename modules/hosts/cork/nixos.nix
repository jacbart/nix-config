{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.cork = {
    username = "meep";
    desktop = "niri";
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/hardware/systemd-boot.nix
      ../../nixos/hardware/nvidia-3060ti.nix
      ../../nixos/hardware/hardwarekey.nix
      ../../nixos/security/acme-hostname.nix
      config.flake.modules.nixos.profileWorkstationMedia
      ../../nixos/services/flatpak.nix
      config.flake.modules.nixos.profileOnlinePersonal
      ../../nixos/apps/ghostty.nix
      ../../nixos/apps/steam.nix
      (
        { pkgs, ... }:
        let
          lm = import ../../nixos/services/mk-leadership-matrix-package.nix { inherit pkgs inputs; };
        in
        {
          services.leadership-matrix.package = lm [
            "nvidia"
            "systemd"
          ];

          # virtualisation
          programs.virt-manager.enable = true;
          users.groups.libvirtd.members = [ "meep" ];
          virtualisation.libvirtd.enable = true;
          virtualisation.spiceUSBRedirection.enable = true;

          boot = {
            kernel.sysctl = {
              "vm.max_map_count" = 16777216;
              "fs.file-max" = 524288;
            };
            initrd = {
              availableKernelModules = [
                "nvme"
                "usb_storage"
              ];
              kernelModules = [ ];
            };
            kernelPackages = pkgs.linuxPackages_6_18;
            kernelModules = [ "kvm-amd" ];
            extraModulePackages = [ ];
            kernelParams = [
              "resume_offset=533760"
              "nosgx"
            ];
            supportedFilesystems = lib.mkForce [ "btrfs" ];
            resumeDevice = "/dev/disk/by-label/nixos";
          };

          # filesystem
          services.btrfs.autoScrub = {
            enable = true;
            interval = "monthly";
            fileSystems = [ "/" ];
          };

          # swap
          zramSwap = {
            enable = true;
            memoryMax = 16 * 1024 * 1024 * 1024; # 16 GB ZRAM
            swapDevices = 2;
            priority = 10;
          };

          networking.useDHCP = lib.mkDefault true;

          # cpu
          nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
          hardware.cpu.amd.updateMicrocode = lib.mkForce true;
        }
      )
      (import ./disks.nix { })
    ];
  };
}
