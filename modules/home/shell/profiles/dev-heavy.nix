{ pkgs, ... }:
{
  imports = [
    ./base.nix
    ../zsh.nix
    ../tools
    ../../apps/newsboat.nix
    ../../apps/fern.nix
    ../../apps/ai
  ];

  home.packages = with pkgs; [
    mdbook
    pgsync
    postgresql_16
    uv
    fern
  ];

  programs.carapace = {
    enable = true;
    package = pkgs.unstable.carapace;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  programs.zsh.shellAliases.summarize = "summarize-commit";
}
