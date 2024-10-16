{ config, pkgs, lib, ... }: let
  inherit (pkgs.stdenv) isLinux;
in {
  home.packages = [
    pkgs.nixd
  ] ++ lib.optionals isLinux [ pkgs.unstable.zed-editor ];

  # add in settings.json
  home.file."${config.xdg.configHome}/zed/settings.json".text = builtins.readFile ./zed-editor.json;
}
