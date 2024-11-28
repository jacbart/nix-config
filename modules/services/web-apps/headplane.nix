{ config
, lib
, pkgs
, ...
}:
let
  hs-cfg = config.services.headscale;

  settingsFormat = pkgs.formats.yaml {};
in
{
  options = {
    services.headplane = {
      enable = lib.mkEnableOption "headplane, An advanced UI for juanfont/headscale";

      package = lib.mkPackageOption pkgs.local "headplane" { };

      user = lib.mkOption {
        default = hs-cfg.user;
        type = lib.types.str;
        description = ''
          User account under which headplane runs.


        '';
      };

      group = lib.mkOption {
        default = hs-cfg.group;
        type = lib.types.str;
        description = ''
          Group under which headplane runs
        '';
      };

      host = lib.mkOption {
        default = hs-cfg.address;
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
        description = '''';
        type = lib.types.submodule {
          freeformType = settingsFormat.type;

          options = {
            config_file = lib.mkOption {
              default = "TODO";
            };
          };
        };
      };
    };
  };
}
