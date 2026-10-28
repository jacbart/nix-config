{ pkgs, ... }:
{
  imports = [
    ./base.nix
    ../zsh.nix
    ../tools
    ../../apps/eilmeldung.nix
    ../../apps/ai
  ];

  home.packages = with pkgs; [
    mdbook
    pgsync
    postgresql_16
    uv
  ];

  programs.carapace = {
    enable = true;
    package = pkgs.unstable.carapace;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  programs.zsh.shellAliases.summarize = "summarize-commit";
}
