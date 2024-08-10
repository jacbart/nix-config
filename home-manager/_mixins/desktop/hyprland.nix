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
        "${pkgs.swww}/bin/swww-daemon &"
        # "${pkgs.swww}/bin/swww img ${config.xdg.dataHome}/images/moose-orange-bg &"
        # "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww"
        # "${pkgs.eww}/bin/eww open bar --screen 0"
      ];
    };

    settings = {
      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
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
          # launchers
          "$mod, D, exec, rofi -show combi"
          "$mod, W, exec, firefox"
          "$mod, T, exec, kitty"
          # reload
          "$mod SHIFT, R, exec, hyprctl reload"
          # window controls
          "$mod, Q, killactive"
          "$mod SHIFT, Q, exit"
          # window resize
          "$mod ALT, h, resizeactive, -160 0"
          "$mod ALT, l, resizeactive, 160 0"
          "$mod ALT, k, resizeactive, 0 -160"
          "$mod ALT, j, resizeactive, 0 160"
          # window focus
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
          # window postion
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"
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
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
          10)
        );
      binde = [
        # cycle windows
        "ALT, TAB, cyclenext"
        "ALT, TAB, bringactivetotop"
        "ALT SHIFT, TAB, cyclenext, prev"
      ];
    };
  };
}
