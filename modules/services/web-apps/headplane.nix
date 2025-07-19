{
  config,
  lib,
  pkgs,
  ...
}:
let
  hs-cfg = config.services.headscale;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options = {
    services.headplane = {
      enable = lib.mkEnableOption "headplane, An advanced UI for juanfont/headscale";

      package = lib.mkPackageOption pkgs.local "headplane" { };

      user = lib.mkOption {
        default = hs-cfg.user or "headscale";
        type = lib.types.str;
        description = ''
          User account under which headplane runs.
        '';
      };

      group = lib.mkOption {
        default = hs-cfg.group or "headscale";
        type = lib.types.str;
        description = ''
          Group under which headplane runs
        '';
      };

      host = lib.mkOption {
        default = hs-cfg.address or "0.0.0.0";
        type = lib.types.str;
        description = ''
          Listening address of headplane
        '';
      };

      port = lib.mkOption {
        default = 3000;
        type = lib.types.port;
        description = ''
          Listening port of headplane
        '';
      };

      headscale = lib.mkOption {
        description = ''
          Configuration related to integrating with the Headscale server.
        '';
        type = lib.types.submodule {
          freeformType = settingsFormat.type;

          options = {
            config_file = lib.mkOption {
              default = "/etc/headscale/config.yaml";
              type = lib.types.path;
              description = "The path to the Headscale config file.";
            };
          };
        };
      };

      cookieSecret = lib.mkOption {
        type = lib.types.str;
        description = ''
          A secret used to sign cookies for Headplane.
        '';
      };

      headscaleUrl = lib.mkOption {
        type = lib.types.str;
        description = ''
          The public URL of your Headscale server.
        '';
      };

      debug = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Enable debug logging for Headplane.
        '';
      };

      cookieSecure = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = ''
          Ensure cookies are sent only over HTTPS.
        '';
      };
    };
  };

  config = lib.mkIf config.services.headplane.enable {
    systemd.services.headplane = {
      description = "Headplane Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = config.services.headplane.user;
        Group = config.services.headplane.group;
        Environment = [
          "COOKIE_SECRET=${config.services.headplane.cookieSecret}"
          "HEADSCALE_URL=${config.services.headplane.headscaleUrl}"
          "DEBUG=${toString config.services.headplane.debug}"
          "HOST=${config.services.headplane.host}"
          "PORT=${toString config.services.headplane.port}"
          "CONFIG_FILE=${config.services.headplane.headscale.config_file}"
          "COOKIE_SECURE=${toString config.services.headplane.cookieSecure}"
        ];
        ExecStart = "${config.services.headplane.package}/bin/headplane";
        Restart = "always";
      };
    };
  };
}
