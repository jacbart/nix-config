{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    (import ./disks.nix { })
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/bluetooth.nix
    ../_mixins/services/pipewire.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "md_mod" "raid0" "raid1" "raid10" "raid456" "ext2" "ext4" "ahci" "sata_nv" "sata_via" "sata_sis" "sata_uli" "ata_piix" "pata_marvell" "sd_mod" "sr_mod" "mmc_block" "uhci_hcd" "ehci_hcd" "ehci_pci" "ohci_hcd" "ohci_pci" "xhci_hcd" "xhci_pci" "usbhid" "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat" "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft" "hid_cherry" "pcips2" "atkbd" "i8042" "rtc_cmos" ];                                                                    
      kernelModules = [ ];                                                                                                                      
    };
    kernelModules = [ "kvm-intel" "bridge" "macvlan" "tap" "tun" "veth" "br_netfilter" "xt_nat" "cpufreq_powersave" "loop" "atkbd" "ctr" ];                                                                                                                 
    extraModulePackages = [ ];
  };

  environment.systemPackages = with pkgs; [
    helix
    btop
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g escape-time 50
      # Window Splitting
      unbind %
      bind | split-window -h -f -c '#{pane_current_path}'
      bind \\ split-window -h -c '#{pane_current_path}'
      bind _ split-window -v -f -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      set -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g mouse on
      set -g status-keys vi
    '';
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
