# Language servers and commented lsp-ai experiment: ./helix-langs.nix
{
  config,
  pkgs,
  ...
}:
let
  helix = pkgs.unstable.helix;
in
{
  home = {
    packages = (import ./helix-packages.nix { inherit pkgs; }) ++ [ pkgs.scripts.hx-go-tags ];

    file."${config.xdg.configHome}/sqls/config.yml".text = builtins.readFile ./sqls.yaml;

    file."${config.xdg.configHome}/scooter/config.toml".text = ''
      [editor_open]
      command = "tmux send-keys -t \"$TMUX_PANE\" ':open \"%file:%line\"' Enter"
      exit = true
    '';

    sessionVariables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs.helix = {
    enable = true;
    package = helix;
    languages = import ./helix-langs.nix;
    settings = import ./helix-settings.nix;
  };
}
