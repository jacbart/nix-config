{ pkgs, ... }:
let
  s = import ./git-shared.nix { inherit pkgs; };
in
{
  home.packages = s.homePackages;
  programs = {
    gh = s.gh;
    git = {
      enable = true;
      settings = s.gitSettingsBase // {
        core = {
          editor = "hx";
          sshCommand = "ssh -i ~/.ssh/id_git";
        };
      };
    };
  };
}
