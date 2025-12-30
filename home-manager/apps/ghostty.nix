{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      theme = "dark:Gruvbox Dark,light:Gruvbox Light";
      shell-integration = "zsh";
      window-decoration = "none";
      maximize = "true";
    };
  };
}
