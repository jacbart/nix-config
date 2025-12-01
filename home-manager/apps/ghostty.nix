{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "dark:Gruvbox Dark,light:Gruvbox Light";
      shell-integration = "zsh";
    };
  };
}
