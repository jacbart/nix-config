{ config
, inputs
, lib
, pkgs
, ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    (import ./disks.nix { })
    ./remote-builder.nix
    ../../hardware/systemd-boot.nix
    ../../services/qemu.nix
    ../../services/docker.nix
    ../../services/bluetooth.nix
    ../../services/pipewire.nix
    ../../services/minio-client.nix
    ../../services/tailscale.nix
    ../../apps/ghostty.nix
    ./virt.nix
  ];

  environment.systemPackages = [
    pkgs.uucp
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
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
        "boojum.meep.sh"
        "remote.dev"
      ];
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    # extraConfig = ''
    #   set -g escape-time 50

    #   # Smart pane switching with awareness of vim splits
    #   is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?)(diff)?$"'
    #   bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
    #   bind -n C-u if-shell "$is_vim" "send-keys C-u" "select-pane -U"
    #   bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
    #   bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

    #   # Window Splitting
    #   unbind %
    #   bind | split-window -h -f -c '#{pane_current_path}'
    #   bind \\ split-window -h -c '#{pane_current_path}'
    #   bind _ split-window -v -f -c '#{pane_current_path}'
    #   bind - split-window -v -c '#{pane_current_path}'

    #   set -g default-terminal "xterm-256color"
    #   set-option -sa terminal-overrides ",xterm*:Tc"
    #   set-option -g mouse on

    #   set -g status-keys vi

    #   # Don't exit copy mode when mouse drags
    #   unbind -T copy-mode-vi MouseDragEnd1Pane
    #   bind-key -T copy-mode-vi Escape send-keys -X cancel

    #   # Pane titles
    #   unbind t
    #   bind t setw pane-border-status
    #   set -g pane-border-format "#{pane_title}"
    #   # Rename pane
    #   unbind T
    #   bind T command-prompt -p "(rename-pane)" -I "#T" "select-pane -T '%%'"
    # '';
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
