{ config, pkgs, ... }: {
  imports = [
    ./hyprland-apps.nix
  ];

  gtk.enable = true;

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
      variables = [ "--all" ];
      extraCommands = [
        "${pkgs.swww}/bin/swww-daemon"
        # "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww"
        # "${pkgs.eww}/bin/eww open bar --screen 0"
      ];
    };

    settings = {
      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      ];

      exec-once = [
        "${pkgs.swww}/bin/swww img ${config.xdg.dataHome}/images/moose-orange-bg"
      ];
      
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
        ", XF86AudioMute, exec, ${config.xdg.dataHome}/zsh/scripts/os/volume_control.zsh toggle"
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
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
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
        ", XF86AudioRaiseVolume, exec, ${config.xdg.dataHome}/zsh/scripts/os/volume_control.zsh up"
        ", XF86AudioLowerVolume, exec, ${config.xdg.dataHome}/zsh/scripts/os/volume_control.zsh down"
        # brightness controls
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
      ];
      bindr = [
        # toggle rofi launcher
        "$mod, D, exec, pkill rofi || rofi -show combi"
        "$mod, Space, exec, pkill rofi || rofi -show combi"
      ];
      windowrulev2 = [
        # auto set pip from firefox as a floating window
        "float,class:(firefox),title:(Picture-in-Picture)"
      ];
    };
  };
}
