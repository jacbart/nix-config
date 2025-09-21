{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "dark:srcery,light:Gruvbox Light";
      shell-integration = "zsh";
    };
  };
}
