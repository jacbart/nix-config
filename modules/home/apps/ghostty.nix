{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      # theme = "dark:Gruvbox Dark,light:Gruvbox Light";
      theme = "Gruvbox Dark";
      shell-integration = "zsh";
      window-decoration = "none";
      # HM keyValue omits quotes; spaced names must be quoted for Ghostty (see ghostty.org config reference).
      font-family = [
        "\"JetBrainsMono Nerd Font Mono\""
        "\"Noto Sans Mono\""
        "\"Noto Sans Mono CJK SC\""
      ];
      font-size = 13;
      # maximize = "true";
    };
  };
}
