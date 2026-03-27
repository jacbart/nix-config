{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nixosHosts.cork = {
    username = "meep";
    desktop = "cosmic";
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/hardware/systemd-boot.nix
      ../../nixos/hardware/nvidia-3060ti.nix
      ../../nixos/hardware/hardwarekey.nix
      ../../nixos/security/acme-hostname.nix
      ../../nixos/services/qemu.nix
      ../../nixos/services/docker.nix
      ../../nixos/services/bluetooth.nix
      ../../nixos/services/pipewire.nix
      ../../nixos/services/flatpak.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/nixupd-client.nix
      ../../nixos/apps/ghostty.nix
      ../../nixos/apps/steam.nix
      ../../nixos/services/leadership-matrix.nix
    ]
    ++ [
      {
        services.leadership-matrix = {
          package = inputs.leadership-matrix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
            cargoFeatures = [
              "nvidia"
              "systemd"
              "smart"
            ];
          };
          services = lib.mkForce [
            "leadership-matrix"
            "tailscaled"
          ];
        };

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

        # networking
        networking = {
          useDHCP = lib.mkDefault true;
          hosts = {
            "127.0.0.2" = [
              "cork.meep.sh"
              "remote.dev"
            ];
          };
        };

        # cpu
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    ]
    ++ [
      (import ./disks.nix { })
    ];
  };
}
