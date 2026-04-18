{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../apps/rustdesk.nix
    ../apps/zed-editor.nix
    ../apps/ghostty.nix
    ../apps/lan-mouse.nix # virtual kvm
    ./personal-services.nix
    ./vivaldi-pwa.nix
    inputs.noctalia.homeModules.default
  ];

  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      geeqie
      wl-clipboard
      vlc
      unstable.librewolf
      unstable.vivaldi
      gimp-with-plugins
      unstable.zoom-us
      unstable.discord
      unstable.slack
    ];
    file."${config.home.homeDirectory}/Pictures/wallpapers/bg.jpg".source = ../files/bg.jpg;
  };

  programs.noctalia-shell = {
    enable = true;
    settings = {
      wallpaper.directory = "${config.home.homeDirectory}/Pictures/wallpapers";
      appLauncher.terminalCommand = "ghostty";
      bar = {
        outerCorners = false;
        position = "top";
        widgets = {
          left = [
            { id = "ActiveWindow"; }
          ];
          center = [
            {
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            { id = "Tray"; }
            # { id = "Tailscale"; }
            # { id = "PrivacyIndicator"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "Clock"; }
          ];
        };
      };
      colorSchemes.predefinedScheme = "kanagawa";
      idle = {
        enabled = true;
        screenOffTimeout = 600;
        lockTimeout = 660;
      };
      nightLight.enabled = true;
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }
      touchpad {
        tap
        natural-scroll
        scroll-factor 0.4
      }
    }

    layout {
      gaps 8
      background-color "transparent"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }
    }

    spawn-at-startup "noctalia-shell"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"

    prefer-no-csd

    debug {
      honor-xdg-activation-with-invalid-serial
    }

    // Noctalia wallpaper layer
    layer-rule {
      match namespace="^noctalia-wallpaper*"
      place-within-backdrop true
    }

    binds {
      // Launcher
      Mod+D { spawn "fuzzel"; }
      Mod+Space { spawn "fuzzel"; }

      // Terminal
      Mod+Return { spawn "ghostty"; }
      Mod+T { spawn "ghostty"; }

      // Browser
      Mod+W { spawn "vivaldi"; }

      // Overview
      Mod+Tab repeat=false { toggle-overview; }

      // Window management
      Mod+Q repeat=false { close-window; }
      Mod+Shift+F { fullscreen-window; }
      Mod+F { maximize-column; }
      Mod+M { maximize-window-to-edges; }
      Mod+Shift+Space { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+Comma { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }
      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }

      // Center
      Mod+C { center-column; }
      Mod+Ctrl+C { center-visible-columns; }

      // Column width
      Mod+R { switch-preset-column-width; }
      Mod+Ctrl+F { expand-column-to-available-width; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Alt+H { set-column-width "-10%"; }
      Mod+Alt+L { set-column-width "+10%"; }
      Mod+Alt+Left { set-column-width "-10%"; }
      Mod+Alt+Right { set-column-width "+10%"; }

      // Window height
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // Focus movement
      Mod+H { focus-column-left; }
      Mod+J { focus-window-or-workspace-down; }
      Mod+K { focus-window-or-workspace-up; }
      Mod+L { focus-column-right; }
      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-or-workspace-down; }
      Mod+Up { focus-window-or-workspace-up; }
      Mod+Right { focus-column-right; }
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }

      // Move windows
      Mod+Ctrl+H { move-column-left; }
      Mod+Ctrl+J { move-window-down; }
      Mod+Ctrl+K { move-window-up; }
      Mod+Ctrl+L { move-column-right; }
      Mod+Ctrl+Left { move-column-left; }
      Mod+Ctrl+Down { move-window-down; }
      Mod+Ctrl+Up { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End { move-column-to-last; }

      // Monitor focus
      Mod+Shift+Left { focus-monitor-left; }
      Mod+Shift+Down { focus-monitor-down; }
      Mod+Shift+Up { focus-monitor-up; }
      Mod+Shift+Right { focus-monitor-right; }

      // Move to monitor
      Mod+Ctrl+Shift+Left { move-column-to-monitor-left; }
      Mod+Ctrl+Shift+Down { move-column-to-monitor-down; }
      Mod+Ctrl+Shift+Up { move-column-to-monitor-up; }
      Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }

      // Workspaces 1-9
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      // Workspace cycling
      Mod+Page_Down { focus-workspace-down; }
      Mod+Page_Up { focus-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up { move-workspace-up; }

      // Wheel scroll
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft { move-column-left; }

      // Screenshot
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      // Clipboard history
      Mod+V { spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

      // Lock screen
      Mod+Escape allow-inhibiting=false { spawn "swaylock"; }

      // Quit
      Mod+Shift+E { quit; }

      // Power off monitors
      // Mod+Shift+P { power-off-monitors; }

      // Volume
      XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

      // Media
      XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
      XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
      XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
      XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }

      // Brightness
      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

      // Alt+Tab window cycling
      Alt+Tab { focus-window-or-monitor-down; }
      Alt+Shift+Tab { focus-window-or-monitor-up; }
    }

    // Window rules
    window-rule {
      match title=r#"(?i)^picture.?in.?picture$"#  // Matches Firefox and Vivaldi PiP
      open-floating true
      default-column-width { fixed 480; }
      default-window-height { fixed 270; }
    }

    window-rule {
      match app-id="1Password"
      open-floating true
    }
  '';
}
