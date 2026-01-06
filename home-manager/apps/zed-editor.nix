{
  # config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.unstable.zed-editor
  ];

  # add in settings.json
  # home.file."${config.xdg.configHome}/zed/settings.json".text = builtins.readFile ./zed-editor.json;
}
