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
    ../../hardware/hardwarekey.nix
    ../../services/qemu.nix
    ../../services/docker.nix
    ../../services/bluetooth.nix
    ../../services/pipewire.nix
    ../../services/flatpak.nix
    ../../services/tailscale.nix
    ../../apps/ghostty.nix
    ../../apps/steam.nix
  ];

  # virtualisation
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
    kernelPackages = pkgs.linuxPackages_latest;
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

  # swap - swap partition declared in disks.nix
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
