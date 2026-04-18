{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.boojum = {
    username = "meep";
    desktop = "niri";
    modules = [
      config.flake.modules.nixos.core
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
      ../../nixos/hardware/systemd-boot.nix
      ../../nixos/security/acme-hostname.nix
      config.flake.modules.nixos.profileWorkstationMedia
      config.flake.modules.nixos.profileOnlinePersonal
      ../../nixos/apps/ghostty.nix
      (
        { pkgs, ... }:
        let
          lm = import ../../nixos/services/mk-leadership-matrix-package.nix { inherit pkgs inputs; };
        in
        {
          services.leadership-matrix.package = lm [ "systemd" ];

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

          networking.useDHCP = lib.mkDefault true;

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

          hardware.cpu.intel.updateMicrocode = lib.mkForce true;
        }
      )
      (import ./disks.nix { })
      ./remote-builder.nix
      ./virt.nix
    ];
  };
}
