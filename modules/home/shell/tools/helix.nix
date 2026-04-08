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
    packages = import ./helix-packages.nix { inherit pkgs; };

    file."${config.xdg.configHome}/sqls/config.yml".text = builtins.readFile ./sqls.yaml;

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
