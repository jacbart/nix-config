{ config, pkgs, ... }: {
  imports = [
    ./hyprland-apps.nix
    ./gtk.nix
  ];

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
        "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww"
        "${pkgs.eww}/bin/eww open-many bar"
      ];
    };

    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod SHIFT, Q, exec, hyprctl kill"
          "$mod, W, exec, firefox"
          "$mod, T, exec, kitty"
          "$mod, D, exec, rofi -show combi"
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
    };
  };
}
