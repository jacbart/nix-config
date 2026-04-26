{ ... }:
{
  flake.modules.nixos.core =
    {
      config,
      inputs,
      overlays,
      lib,
      pkgs,
      vars,
      stateVersion,
      desktop,
      ...
    }:
    let
      hasDesktop = desktop != null;
    in
    {
      imports = [
        ./libraries
      ];
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
        # UTF-8 locale data for apps that set LC_* to zh/ru/etc. (glyphs still need fonts below)
        supportedLocales = [
          "C.UTF-8/UTF-8"
          "en_US.UTF-8/UTF-8"
          "ru_RU.UTF-8/UTF-8"
          "zh_CN.UTF-8/UTF-8"
          "ja_JP.UTF-8/UTF-8"
        ];
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
      time.timeZone = lib.mkDefault vars.timezone;

      # Only install the docs I use
      documentation.enable = true;
      documentation.nixos.enable = false;
      documentation.man.enable = true;
      documentation.info.enable = false;
      documentation.doc.enable = false;

      environment = {
        # Eject nano and perl from the system
        defaultPackages = lib.mkForce [
          pkgs.gitMinimal
          pkgs.home-manager
          pkgs.helix
          pkgs.rsync
        ];
        systemPackages = with pkgs; [
          bottom
          cyme
          kexec-tools
          pciutils
          psmisc
          sops
          unzip
          usbutils
        ];
        variables = {
          EDITOR = "hx";
          SYSTEMD_EDITOR = "hx";
          VISUAL = "hx";
        };
      };

      fonts = lib.mkIf hasDesktop {
        fontDir.enable = true;
        packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.hack
          nerd-fonts.jetbrains-mono
          nerd-fonts.sauce-code-pro
          nerd-fonts.ubuntu-mono
          fira
          fira-go
          joypixels
          liberation_ttf
          # Broad Unicode coverage for browsers / UI (enableDefaultPackages is off)
          noto-fonts
          # Han/Hangul/Kana (not in noto-fonts LGC)
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          source-serif
          ubuntu-classic
          work-sans
        ];

        # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
        enableDefaultPackages = false;

        fontconfig = {
          antialias = true;
          defaultFonts = {
            serif = [
              "Source Serif"
              "Noto Serif"
            ];
            sansSerif = [
              "Work Sans"
              "Fira Sans"
              "FiraGO"
              "Noto Sans CJK SC"
              "Noto Sans"
            ];
            monospace = [
              "FiraCode Nerd Font Mono"
              "SauceCodePro Nerd Font Mono"
              "Noto Sans Mono CJK SC"
              "Noto Sans Mono"
            ];
            emoji = [
              "Joypixels"
              "Noto Color Emoji"
            ];
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

      # Basic networking defaults - hostname should be set at host level
      networking = {
        useDHCP = lib.mkDefault true;
        # StevenBlack unified hosts: ad/malware sinkhole (see https://github.com/StevenBlack/hosts).
        # Extra lists: fakenews, gambling, porn, social — add to `block` if you want them.
        stevenblack = {
          enable = true;
        };
      };

      nixpkgs = {
        overlays = lib.attrValues overlays;
        # Configure your nixpkgs instance
        config = {
          # Disable if you don't want unfree packages
          allowUnfree = true;
          # Accept the joypixels license
          joypixels.acceptLicense = true;
        };
      };

      nix = {
        package = pkgs.lixPackageSets.latest.lix;
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
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          allowed-uris = vars.nixAllowedUris;

          # Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;

          warn-dirty = false;

          substituters = vars.nixSubstitutersNixOS;
          trusted-public-keys = vars.nixTrustedPublicKeysNixOS;
        };
      };

      programs = {
        command-not-found.enable = false;
        zsh = {
          enable = true;
        };
      };

      services.fwupd.enable = lib.mkIf hasDesktop true;

      system.activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        '';
      };
      system.stateVersion = stateVersion;
    };
}
