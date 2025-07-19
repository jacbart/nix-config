{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "dark:gruvbox-material,light:GruvboxLight";
      shell-integration = "zsh";
    };
  };
}
