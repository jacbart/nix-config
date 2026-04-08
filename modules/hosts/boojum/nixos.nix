{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.boojum = {
    username = "meep";
    desktop = "cosmic";
    modules = [
      # Core modules
      config.flake.modules.nixos.core
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen

      # Hardware
      ../../nixos/hardware/systemd-boot.nix

      # Security
      ../../nixos/security/acme-hostname.nix

      # Services
      ../../nixos/services/qemu.nix
      ../../nixos/services/docker.nix
      ../../nixos/services/bluetooth.nix
      ../../nixos/services/pipewire.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/leadership-matrix.nix
      ../../nixos/services/nixupd-client.nix

      # Apps
      ../../nixos/apps/ghostty.nix

      # Host-specific config
      (
        { pkgs, ... }:
        {
          services.leadership-matrix = {
            package = import ../../nixos/services/leadership-matrix-package.nix {
              inherit pkgs inputs;
              cargoFeatures = [ "systemd" ];
            };
          };

          environment.systemPackages = [
            pkgs.uucp
            pkgs.gparted
          ];

          boot = {
            initrd = {
              availableKernelModules = [
                "xhci_pci"
                "nvme"
                "usb_storage"
                "sd_mod"
              ];
              kernelModules = [ ];
            };
            kernelModules = [ "kvm-intel" ];
            extraModulePackages = [ ];
            kernelParams = [
              "resume_offset=533760"
              "nosgx"
            ];
            supportedFilesystems = lib.mkForce [ "btrfs" ];
            kernelPackages = pkgs.linuxPackages_latest;
            resumeDevice = "/dev/disk/by-label/nixos";
          };

          networking = {
            hosts = {
              "127.0.0.2" = [
                "boojum.meep.sh"
                "remote.dev"
              ];
            };
            useDHCP = lib.mkDefault true;
          };

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

          hardware.cpu.intel.updateMicrocode = lib.mkForce true;
        }
      )

      # Host-specific files
      (import ./disks.nix { })
      ./remote-builder.nix
      ./virt.nix
    ];
  };
}
