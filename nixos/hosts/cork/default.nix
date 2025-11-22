{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    (import ./disks.nix { })
    ../../hardware/systemd-boot.nix
    ../../services/qemu.nix
    ../../services/docker.nix
    ../../services/bluetooth.nix
    ../../services/pipewire.nix
    ../../services/tailscale.nix
    ../../apps/ghostty.nix
  ];

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ username ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

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
    # hostId = "";
    hosts = {
      "127.0.0.2" = [
        "cork.meep.sh"
        "remote.dev"
      ];
    };
  };
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
