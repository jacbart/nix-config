{ pkgs, config, ... }:
let
  s = import ./git-shared.nix { inherit pkgs; };
in
{
  home.packages = s.homePackages;
  programs = {
    gh = s.gh;
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    git = {
      enable = true;
      settings = s.gitSettingsBase // {
        core.editor = "hx";
        safe.directory = [
          "${config.home.homeDirectory}/workspace/*"
          "/git/*"
        ];
      };
    };
  };
}
