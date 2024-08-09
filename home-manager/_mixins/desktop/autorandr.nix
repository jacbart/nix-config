{ config, pkgs, ... }:
let
  mkOption = pkgs.lib.mkOption;
  types = pkgs.lib.types;
  cfg = config.my-autorandr;
in {
  options =
    let
      xrandr-display = types.enum [
        "eDP-1"
        "DP-1"
        "HDMI-1"
        "DP-2"
        "HDMI-2"
        "DP-3"
        "HDMI-3"
        "DP-1-4"
        "DP-1-5"
        "DP-1-6"
        "eDP-1-2"
      ];
      displayOptions = {
        options = {
          name = mkOption {
            description = "xrandr name for the display";
            type = xrandr-display;
          };
          fp = mkOption {
            description = "value from 'autorandr --fingerprint'";
            type = types.str;
          };
        };
      };
      in {
        my-autorandr = {
          display1 = mkOption {
            description = "main display for custom layouts";
            type = types.submodule displayOptions;
          };
          display2 = mkOption {
            description = "secondary display for custom layouts";
            type = types.submodule displayOptions;
          };
        };
  };
  config = {
    programs.autorandr = {
      profiles = {
        both = {
          config = {
            "${cfg.display1.name}" = {
              enable = true;
              mode = "1920x1080";
              primary = true;
              position = "0x0";
              rate = "60.00";
              crtc = 1;
            };
            "${cfg.display2.name}" = {
              enable = true;
              mode = "1920x1080";
              position = "1920x0";
              rate = "60.00";
              crtc = 0;
            };
          };
          fingerprint = {
            "${cfg.display1.name}" = "${cfg.display1.fp}";
            "${cfg.display2.name}" = "${cfg.display2.fp}";
          };
        };
        external = {
          config = {
            "${cfg.display2.name}" = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.00";
              crtc = 0;
            };
          };
          fingerprint = {
            "${cfg.display1.name}" = "${cfg.display1.fp}";
            "${cfg.display2.name}" = "${cfg.display2.fp}";
          };
        };
        primary = {
          config = {
            "${cfg.display1.name}" = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.00";
              crtc = 0;
            };
          };
          fingerprint = {
            "${cfg.display1.name}" = "${cfg.display1.fp}";
          };
        };
      };
    };
  };
}