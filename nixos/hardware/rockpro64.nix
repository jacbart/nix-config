# Pine64 RockPro64 (RK3399 SoC) hardware configuration.
# big.LITTLE: 2x Cortex-A72 + 4x Cortex-A53, 4GB LPDDR4
{
  lib,
  pkgs,
  ...
}:
{
  boot = {
    initrd.availableKernelModules = [
      "ahci" # SATA (via PCIe SATA adapter)
      "usbhid" # USB input devices
      "sdhci_of_arasan" # eMMC/SD controller (boot device)
    ];

    initrd.kernelModules = [
      # PCIe (required for SATA adapter / NVMe)
      "pcie_rockchip_host"
      "phy_rockchip_pcie"
      # Network (GbE MAC driver for RTL8211F PHY)
      "dwmac_rk"
      # Rockchip SoC
      "rockchip_rga"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"
    ];

    kernelModules = [
      "tcp_bbr" # BBR congestion control
      "rk_crypto" # RK3399 hardware crypto (AES/SHA)
      "pwm_rockchip" # PWM for fan control
    ];

    kernelParams = [
      # Serial console (RK3399 UART2 at 1.5Mbaud)
      "console=ttyS2,1500000"
      "console=tty0"
      # DMA: reserve contiguous memory for PCIe SATA/USB transfers
      "cma=128M"
      "coherent_pool=2M"
      # Disable audit subsystem (unnecessary on homelab server)
      "audit=0"
    ];

    extraModulePackages = [ ];
  };

  # schedutil integrates with the kernel scheduler and is the recommended
  # governor for big.LITTLE architectures -- better perf-per-watt and
  # faster response to load changes than ondemand's polling approach.
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # Firmware for peripherals (RTL8211F PHY, etc.)
  hardware.enableRedistributableFirmware = true;

  # ── Ethernet hardware checksum offload fix ────────────────────────────
  # The RK3399 GMAC (Synopsys DesignWare MAC) has a known bug where
  # hardware checksumming of large packets causes corruption.
  # Documented: https://wiki.nixos.org/wiki/NixOS_on_ARM/PINE64_ROCKPro64
  systemd.services.disable-ethernet-offload = {
    description = "Disable RK3399 GMAC hardware checksum offload (known bug)";
    after = [ "network-pre.target" ];
    before = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.ethtool ];
    script = ''
      ethtool -K eth0 rx off tx off 2>/dev/null || true
    '';
  };

  # ── Fan control (RockPro64 NAS case PWM fan) ──────────────────────────
  # Ramps fan speed based on CPU thermal zone temperature.
  # Fan starts at 40C, full speed at 80C.
  hardware.fancontrol = {
    enable = lib.mkDefault true;
    config = lib.mkDefault ''
      INTERVAL=3
      DEVPATH=hwmon0=devices/virtual/thermal/thermal_zone0 hwmon1=devices/virtual/thermal/thermal_zone1 hwmon3=devices/platform/pwm-fan
      DEVNAME=hwmon0=cpu_thermal hwmon1=gpu_thermal hwmon3=pwmfan
      FCTEMPS=hwmon3/pwm1=hwmon0/temp1_input
      MINTEMP=hwmon3/pwm1=40
      MAXTEMP=hwmon3/pwm1=80
      MINSTART=hwmon3/pwm1=35
      MINSTOP=hwmon3/pwm1=30
      MINPWM=hwmon3/pwm1=0
      MAXPWM=hwmon3/pwm1=255
    '';
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
