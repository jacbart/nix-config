{ pkgs }:
{
  homePackages = with pkgs; [
    commitizen
    delta
    scripts.gitclean
  ];

  gh = {
    enable = true;
    extensions = with pkgs; [ gh-markdown-preview ];
    settings = {
      editor = "hx";
      git_protocol = "ssh";
      prompt = "enable";
    };
  };

  gitSettingsBase = {
    user = {
      name = "jacbart";
      email = "jacbart@gmail.com";
      signingkey = "~/.ssh/id_git";
    };
    alias = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      cc = "cz commit";
      ck = "cz check";
      cl = "cz changelog";
      cv = "cz version";
    };
    url = {
      "git@github.com:jacbart" = {
        insteadOf = "https://github.com/jacbart";
      };
      "git@github.com:taybart" = {
        insteadOf = "https://github.com/taybart";
      };
      "git@github.com:journeyai" = {
        insteadOf = "https://github.com/journeyai";
      };
      "git@github.com:journeyid" = {
        insteadOf = "https://github.com/journeyid";
      };
    };
    push.default = "current";
    # First `git push` on a new branch sets upstream (no more `git pull` without tracking).
    push.autoSetupRemote = true;
    pull.rebase = false;
    fetch.prune = true;
    rerere.enabled = true;
    init.defaultBranch = "main";
    merge.conflictStyle = "zdiff3";
    diff.algorithm = "histogram";
    column.ui = "auto";
    gpg.format = "ssh";
    commit.gpgsign = true;
  };
}
