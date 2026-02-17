{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    unstable.broot
    mupdf-headless
    scripts.br
  ];
  home.file = {
    # add broot config
    "${config.xdg.configHome}/broot/conf.hjson".text = builtins.readFile ./broot/conf.hjson;
    "${config.xdg.configHome}/broot/verbs.hjson".text = builtins.readFile ./broot/verbs.hjson;
    "${config.xdg.configHome}/broot/skins/dark-gruvbox.hjson".text =
      builtins.readFile ./broot/skins/dark-gruvbox.hjson;
    "${config.xdg.configHome}/broot/skins/white.hjson".text =
      builtins.readFile ./broot/skins/white.hjson;
  };
}
