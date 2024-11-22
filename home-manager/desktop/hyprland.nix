{ config
, pkgs
, lib
, ...
}: {
  imports = [
    ./hyprland-apps.nix
  ];

  # gtk.enable = true;
  # home.packages = with pkgs;[
  # auth popup
  # polkit-kde-agent
  # ];

  services = {
    gpg-agent.pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit.Description = "polkit-gnome-authentication-agent-1";
    Install.WantedBy = [ "hyprland-session.target" ];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      # variables = [ "--all" ];
      # extraCommands = [];
    };

    settings = {
      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      ];

      exec-once = [
        # wallpaper daemon
        "${pkgs.swww}/bin/swww-daemon"
        # panel/widget daemon
        "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww"

        # open wallpaper
        "${pkgs.swww}/bin/swww img ${config.xdg.dataHome}/images/moose-orange-bg"
        # open top bar
        "${pkgs.eww}/bin/eww open bar --screen 0"
      ];

      input = {
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.4;
        };
      };
      gestures = {
        workspace_swipe = true;
      };

      "$mod" = "SUPER";

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bind =
        [
          # toggle mute
          ", XF86AudioMute, exec, volume toggle"
          # ", XF86AudioMicMute, exec, "
          # launchers
          "$mod, W, exec, firefox"
          "$mod, T, exec, kitty"
          "$mod, Return, exec, kitty"
          # reload
          "$mod, R, exec, hyprctl reload"
          "$mod SHIFT, R, exit"
          # window controls
          "$mod, Q, killactive"
          "$mod SHIFT, Q, exec, hyprctl kill"
          "$mod SHIFT, S, togglefloating"
          "$mod SHIFT, F, fullscreen"
          # window resize
          "$mod ALT, H, resizeactive, -160 0"
          "$mod ALT, L, resizeactive, 160 0"
          "$mod ALT, K, resizeactive, 0 -160"
          "$mod ALT, J, resizeactive, 0 160"
          "$mod ALT, LEFT, resizeactive, -160 0"
          "$mod ALT, RIGHT, resizeactive, 160 0"
          "$mod ALT, UP, resizeactive, 0 -160"
          "$mod ALT, DOWN, resizeactive, 0 160"
          # window focus
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, LEFT, movefocus, l"
          "$mod, RIGHT, movefocus, r"
          "$mod, UP, movefocus, u"
          "$mod, DOWN, movefocus, d"
          # window postion
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, LEFT, movewindow, l"
          "$mod SHIFT, RIGHT, movewindow, r"
          "$mod SHIFT, UP, movewindow, u"
          "$mod SHIFT, DOWN, movewindow, d"
          # workspace cycle
          "$mod, Tab, workspace,previous"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList
            (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod, ${ws}, exec, dunstify -h string:x-canonical-private-synchronous:ws \"Workspace ${toString (x + 1)}\""
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, exec, dunstify -h string:x-canonical-private-synchronous:ws \"Moved => Workspace ${toString (x + 1)}\""
              ]
            )
            10)
        );
      binde = [
        # cycle windows
        "ALT, TAB, cyclenext"
        "ALT, TAB, bringactivetotop"
        "ALT SHIFT, TAB, cyclenext, prev"
        # volume controls
        ", XF86AudioRaiseVolume, exec, volume up"
        ", XF86AudioLowerVolume, exec, volume down"
        # brightness controls
        ", XF86MonBrightnessDown, exec, brightness down"
        ", XF86MonBrightnessUp, exec, brightness up"
      ];
      bindr = [
        # toggle rofi launcher
        "$mod, D, exec, pkill rofi || rofi -show combi"
        "$mod, Space, exec, pkill rofi || rofi -show combi"
      ];
      misc = {
        background_color = "rgb(69, 71, 90)";
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        animate_manual_resizes = true;
      };
      windowrulev2 = [
        # only allow shadows for floating windows
        "noshadow, floating:0"

        # idle inhibit while watching videos
        "idleinhibit focus, class:^(mpv|.+exe)$"
        "idleinhibit fullscreen, class:.*"

        # make Firefox PiP window floating and sticky
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        "float, class:^(1Password)$"
        "stayfocused,title:^(Quick Access — 1Password)$"
        "dimaround,title:^(Quick Access — 1Password)$"
        "noanim,title:^(Quick Access — 1Password)$"

        # make pop-up file dialogs floating, centred, and pinned
        "float, title:(Open|Progress|Save File)"
        "center, title:(Open|Progress|Save File)"
        "pin, title:(Open|Progress|Save File)"
        "float, class:^(code)$"
        "center, class:^(code)$"
        "pin, class:^(code)$"

        # throw sharing indicators away
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
      ];
      xwayland = {
        force_zero_scaling = true;
      };
    };
  };
}
