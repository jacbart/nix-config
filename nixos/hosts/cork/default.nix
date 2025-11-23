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
    ../../hardware/nvidia-3060ti.nix
    ../../services/qemu.nix
    ../../services/docker.nix
    ../../services/bluetooth.nix
    ../../services/pipewire.nix
    ../../services/flatpak.nix
    ../../services/tailscale.nix
    ../../apps/ghostty.nix
    ../../apps/steam.nix
  ];

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ username ];
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
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernelParams = [
      "resume_offset=533760"
      "nosgx"
    ];
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8 GB Swap
    }
  ];
  zramSwap = {
    enable = true;
    memoryMax = 16 * 1024 * 1024 * 1024; # 16 GB ZRAM
  };

  networking = {
    hosts = {
      "127.0.0.2" = [
        "cork.meep.sh"
        "remote.dev"
      ];
    };
  };
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
