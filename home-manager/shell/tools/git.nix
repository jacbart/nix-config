{ pkgs, ... }:
{
  home.packages = with pkgs; [
    commitizen
    delta
  ];
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "hx";
        git_protocol = "ssh";
        prompt = "enable";
      };
    };
    git = {
      enable = true;
      extraConfig = {
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
        core = {
          editor = "hx";
          sshCommand = "ssh -i ~/.ssh/id_git";
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
        push = {
          default = "current";
        };
        pull = {
          rebase = false;
        };
        init = {
          defaultBranch = "main";
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
        # delta = {
        #     enable = true;
        #     options = {
        #         features = "decorations";
        #         navigate = true;
        #         side-by-side = true;
        #     };
        # };
      };
    };
  };
}
