{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, platform, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.vscode-server.nixosModules.default

    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_mixins/services/firewall.nix
    ./_mixins/services/openssh.nix
    ./_mixins/users/root
    ./_mixins/security
  ]
  ++ lib.optional (builtins.pathExists (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
  ++ lib.optional (desktop != null) ./_mixins/desktop
  ++ lib.optional (hostname != "ash") ./_mixins/services/smartmon.nix;

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  time.timeZone = "America/Phoenix";

  # Only install the docs I use
  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = true;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; lib.mkForce [
      gitMinimal
      home-manager
      helix
      rsync
    ];
    systemPackages = with pkgs; [
      kexec-tools
      pciutils
      psmisc
      sops
      unzip
      usbutils
      wget
    ];
    variables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
      fira
      fira-go
      joypixels
      liberation_ttf
      noto-fonts-emoji
      source-serif
      ubuntu_font_family
      work-sans
    ];

    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultPackages = false;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
        emoji = [ "Joypixels" "Noto Color Emoji" ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };

  # Use passed hostname to configure basic networking
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    networkmanager.enable = lib.mkDefault true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+https://git.vdx.hu/"
        "git+ssh://github.com/"
      ];

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      warn-dirty = false;

      # personal substituters
      substituters = [
        "https://s3.meep.sh/nix-cache"
      ];
      trusted-public-keys = [
        "s3.meep.sh-1:uq1p0xwqQ+27BixEKQAmH/WF5jWe4hu4DO5xJ2GOy+w=" # maple
        "s3.meep.sh-2:P0roq43phk+GPx8j96sOsMLS0HkwXdHEEGy6Evjof70=" # ash
        "s3.meep.sh-3:mcrDvp6CZgkpq+/aRB18b6XtJywHSPkSZWr4NrnVGOc=" # boojum
      ];
    };
  };

  programs = {
    command-not-found.enable = false;
    zsh = {
      enable = true;
      shellAliases = {
        nix-gc = "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
        rebuild-all = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config && home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-home = "home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config";
        rebuild-lock = "pushd $HOME/workspace/personal/nix-config && nix flake update && popd";
        rebuild-iso-console = "sudo true && pushd $HOME/workspace/personal/nix-config && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-console/nixos.iso && popd";
        rebuild-iso-desktop = "sudo true && pushd $HOME/workspace/personal/nix-config && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-desktop/nixos.iso && popd";
      };
    };
  };

  services.fwupd.enable = true;

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
  ];

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  };
  system.stateVersion = stateVersion;
  
  nixpkgs.hostPlatform = platform;
}
