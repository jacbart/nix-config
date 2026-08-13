{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  handheld = config.niri-desktop.handheld;
  # uConsole panel max_brightness is 9 — step in raw units, not percent.
  brightnessUpArg = if handheld then "+1" else "5%+";
  brightnessDownArg = if handheld then "1-" else "5%-";
  # ghostty on the CM4 renders via llvmpipe (V3D tops out at GL 3.1); foot is
  # the GL-free fallback terminal the nixos niri module installs on handhelds.
  terminal = if handheld then "foot" else "ghostty";
in
{
  options.niri-desktop.handheld = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Optimize niri for a handheld device (uConsole: no lan-mouse/zed/rustdesk, no heavy apps, DSI-1 output config, raw brightness steps, no screen-off idle).";
  };

  imports = [
    ../apps/ghostty.nix
    ../apps/wayvnc.nix # VNC server bound to tailscale0
    ./personal-services.nix
    ./vivaldi-pwa.nix
    inputs.noctalia.homeModules.default
    # lan-mouse flake module (always imported for the option; enabled
    # conditionally in config below). Inlined from ../apps/lan-mouse.nix
    # to avoid conditional imports (which cause infinite recursion).
    inputs.lan-mouse.homeManagerModules.default
  ];

  config = {
    home = {
      packages =
        with pkgs;
        [
          unstable.bitwarden-desktop
          unstable.element-desktop
          geeqie
          wl-clipboard
          vlc
          unstable.librewolf
          unstable.vivaldi
        ]
        ++ lib.optionals (!handheld) [
          rustdesk # remote desktop client (inlined from ../apps/rustdesk.nix)
          unstable.zed-editor # GPU-accelerated editor (inlined from ../apps/zed-editor.nix)
          gimp-with-plugins
          unstable.zoom-us
          unstable.discord
          unstable.slack
        ];
      file."${config.home.homeDirectory}/Pictures/wallpapers/bg.jpg".source = ../files/bg.jpg;
    };

    # lan-mouse: virtual KVM for desk machines. Inlined from
    # ../apps/lan-mouse.nix to gate on handheld without conditional imports.
    programs.lan-mouse = lib.mkIf (!handheld) {
      enable = true;
      package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
      systemd = !pkgs.stdenv.isDarwin;
      settings =
        if pkgs.stdenv.isDarwin then
          {
            capture-backend = "macos";
            release_bind = [
              "KeyA"
              "KeyS"
              "KeyD"
              "KeyF"
            ];
            port = 4242;
            clients = [
              {
                position = "right";
                hostname = "cork";
                activate_on_startup = false;
                ips = [
                  "192.168.0.137"
                  "100.113.192.12"
                ];
                port = 4242;
              }
            ];
            authorized_fingerprints = {
              "f1:bd:d1:77:33:22:08:6a:1a:b9:d5:6a:fc:c5:78:c2:f9:34:99:50:95:65:c8:8c:c3:92:c3:6d:57:13:16:18" =
                "cork-inbound";
            };
          }
        else
          {
            capture-backend = "layer-shell";
            release_bind = [
              "KeyA"
              "KeyS"
              "KeyD"
              "KeyF"
            ];
            port = 4242;
            clients = [
              {
                position = "left";
                hostname = "sycamore.local";
                activate_on_startup = true;
                ips = [ "192.168.0.30" ];
                port = 4242;
              }
            ];
          };
    };

    programs.noctalia = {
      enable = true;
      settings = {
        wallpaper.directory = "${config.home.homeDirectory}/Pictures/wallpapers";
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Kanagawa";
        };
        nightlight.enabled = true;
        idle = {
          behavior = {
            lock = {
              enabled = true;
              timeout = 660;
              # noctalia v5 built-in action; the old "noctalia:session lock"
              # string was v4 IPC and is ignored with a warning.
              action = "lock";
            };
            "screen-off" = {
              # The CWU50 panel's DPMS off/on path is flaky (dim -> wake goes
              # through the same path as the cold-boot dark-panel quirk).
              # Disable screen-off on handheld; the panel stays on and lock
              # alone protects the session.
              enabled = !handheld;
              timeout = 600;
              action = "screen_off";
            };
          };
        };
        bar = {
          main = {
            position = "top";
            radius = 0;
            # Handheld: trackball-clickable launcher button (uConsole has no
            # dedicated Super key, so keybinds alone aren't enough there).
            start = lib.optionals handheld [ "fuzzel_button" ] ++ [ "active_window" ];
            center = [ "workspaces" ];
            end = [
              "tray"
              # "tailscale"
              # "privacy-indicator"
              "volume"
              "brightness"
              "clock"
            ];
          };
        };
        widget = {
          # v4's settings.display = "none" is gone in v5 (warned + ignored);
          # this is the equivalent: workspace pills without number labels.
          workspaces = {
            show_labels = false;
          };
        }
        // lib.optionalAttrs handheld {
          # Bar button that launches fuzzel (noctalia v5 custom_button widget).
          fuzzel_button = {
            type = "custom_button";
            glyph = "grid-dots";
            tooltip = "Launcher";
            command = "fuzzel";
          };
        };
      };
    };

    xdg.configFile."niri/config.kdl".text = ''
      ${lib.optionalString handheld ''
        // uConsole CWU50 panel: 720x1280 portrait, mounted landscape. The
        // kernel exports the mounting via the DRM "panel orientation"
        // property, and niri ADDS it to the configured transform — so the
        // transform must stay normal here (normal + panel-orientation 90°
        // = correct landscape). A configured "270" cancels the auto-rotation
        // (270+90=360=normal) and leaves the desktop sideways. Mode has no
        // @refresh: the panel only advertises 720x1280@59.597, and an exact
        // @60 match would warn and fall back to preferred anyway. Scale 1.5:
        // the 5" panel is ~297 DPI, so scale 1 is unreadably small (853x480
        // logical); scale 2 (640x360) overflows dialogs.
        output "DSI-1" {
          mode "720x1280"
          scale 1.5
        }
      ''}
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

      spawn-at-startup "noctalia"
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
        Mod+Return { spawn "${terminal}"; }
        Mod+T { spawn "${terminal}"; }

        // Browser
        Mod+W { spawn "vivaldi"; }
        ${lib.optionalString handheld ''
          // Handheld (uConsole): Super is only reachable as an Fn+Cmd chord,
          // so mirror the essentials on Alt (a first-class key on its keyboard).
          Alt+D { spawn "fuzzel"; }
          Alt+Space { spawn "fuzzel"; }
          Alt+Return { spawn "${terminal}"; }
          Alt+T { spawn "${terminal}"; }
          Alt+W { spawn "vivaldi"; }
          Alt+Q repeat=false { close-window; }
          Alt+H { focus-column-left; }
          Alt+J { focus-window-or-workspace-down; }
          Alt+K { focus-window-or-workspace-up; }
          Alt+L { focus-column-right; }
          Alt+Left { focus-column-left; }
          Alt+Down { focus-window-or-workspace-down; }
          Alt+Up { focus-window-or-workspace-up; }
          Alt+Right { focus-column-right; }
          Alt+1 { focus-workspace 1; }
          Alt+2 { focus-workspace 2; }
          Alt+3 { focus-workspace 3; }
          Alt+4 { focus-workspace 4; }
          Alt+5 { focus-workspace 5; }
          Alt+6 { focus-workspace 6; }
          Alt+7 { focus-workspace 7; }
          Alt+8 { focus-workspace 8; }
          Alt+9 { focus-workspace 9; }
          Alt+Escape allow-inhibiting=false { spawn "swaylock"; }
          Alt+Shift+E { quit; }
        ''}

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

        // Brightness — uConsole panel max_brightness is 9, so step in raw
        // units (+1 / 1-) on handheld; percent on desk machines.
        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "${brightnessUpArg}"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "${brightnessDownArg}"; }

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
  };
}
