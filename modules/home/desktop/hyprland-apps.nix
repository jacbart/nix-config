{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../apps/dunst.nix # notifications
    ../apps/eww.nix # panels and widgets
    ../apps/kitty.nix # terminal
    # ../apps/lan-mouse.nix # virtual kvm
    ../apps/rofi-wayland.nix # app launcher
    ../../scripts
  ];

  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      unstable.libreoffice-qt6-fresh # office document viewer
      unstable.geeqie # image veiwer
      brightnessctl # screen brightness controls
      swww # wallpaper
      vlc # multi-media viewer
    ];

    file."${config.xdg.dataHome}/images/bg.jpg".source = ../files/bg.jpg;
  };

  programs = {
    hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "${config.xdg.dataHome}/images/bg.jpg";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
            shadow_passes = 2;
          }
        ];
      };
    };
  };

  services = {
    hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }

          # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }

          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }

          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }

          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };
  };
}
