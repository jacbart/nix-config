{
  lib,
  pkgs,
  config,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      # Serial console for headless management
      "console=ttyS0,115200n8"
      "console=tty0"
    ];

    kernelModules = [
      "igb" # Intel i211 NIC driver
      "tcp_bbr" # BBR congestion control
      "nf_conntrack" # Connection tracking
      "nft_flow_offload" # nftables flow offloading
      "iTCO_wdt" # Intel TCO watchdog timer
      "coretemp" # CPU temperature monitoring
      "kvm-intel" # Virtualization (VT-x)
    ];

    initrd.availableKernelModules = [
      "ahci" # SATA (mSATA SSD)
      "xhci_pci" # USB 3.0
      "usb_storage" # USB storage
      "sd_mod" # SCSI disk
      "sdhci_pci" # SD card reader (if present)
    ];

    # Bootloader
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
      systemd-boot.enable = true;
      timeout = 5;
    };
  };

  # Power management tuned for always-on appliance use
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "performance";
    enable = true;
  };

  # Hardware-specific firmware and microcode
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # No desktop/display needed
  services.xserver.enable = false;

  # Serial console for headless management via ttyS0
  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
  };
}
