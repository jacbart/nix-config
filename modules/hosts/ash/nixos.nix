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
    desktop = "niri";
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/hardware/uconsole.nix
      # Panel cold-boot heal + suspend disable (see module comments).
      # Hacks are gated on the `desktop` arg: phosh gets actkbd +
      # Mutter rotate; niri gets a greetd restart.
      ../../nixos/hardware/uconsole-display.nix
      # NM with the iwd backend. Without this, NM defaults to wpa_supplicant
      # which is not installed -> wlan0 "unavailable".
      ../../nixos/services/networkmanager.nix
      # Avahi: mDNS/DNS-SD for Moonlight host discovery (finds cork on LAN).
      ../../nixos/services/avahi.nix
      # Bluetooth: the BT hardware fix (bt_pins DT overlay) is in the
      # nixos-uconsole kernel module; this enables the userspace stack.
      ../../nixos/services/bluetooth.nix
      # Audio: pipewire + wireplumber. The BCM2711 onboard audio driver is
      # configured via snd_bcm2835 kernel params in uconsole.nix.
      ../../nixos/services/pipewire.nix
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

          sdImage.compressImage = true;

          # Handheld optimizations: disables power-profiles-daemon (conflicts
          # with cpuFreqGovernor=ondemand), sets GSK_RENDERER=ngl (GTK4 Vulkan
          # crashes on v3dv), adds foot (GL-free terminal fallback).
          niri-desktop.handheld = true;

          # Bring-up diagnostics: text boot instead of the plymouth splash so
          # boot progress/stalls are visible on the panel.
          boot.plymouth.enable = lib.mkForce false;

          environment.systemPackages = with pkgs; [
            uconsole-nx
          ];

          # zram first (fast), SD swapfile only as backstop.
          zramSwap.enable = true;
          zramSwap.priority = 100; # default 5 would tie with the swapfile
          swapDevices = [
            {
              device = "/var/lib/swapfile";
              size = 16 * 1024;
              priority = 5;
            }
          ];

          # The stock mkswap service zero-fills the file with dd; at SD card
          # speeds 16G takes ~7min *and blocks sysinit*, so the first boots
          # never reach the desktop. fallocate is instant on ext4. Also order
          # after first-boot partition expansion, else the 10.8G image has no
          # room for the file and creation fails outright.
          systemd.services."mkswap-var-lib-swapfile" = {
            after = [ "expand-root-partition.service" ];
            script = lib.mkForce ''
              currentSize=$(( $(stat -c "%s" "$DEVICE" 2>/dev/null || echo 0) / 1024 / 1024 ))
              if [[ ! -b "$DEVICE" && "16384" != "$currentSize" ]]; then
                echo "Creating swap file using fallocate and mkswap."
                mkdir -p "$(dirname "$DEVICE")"
                rm -f "$DEVICE"
                fallocate -l 16384M "$DEVICE"
                chmod 600 "$DEVICE"
                mkswap "$DEVICE"
              fi
            '';
          };

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
