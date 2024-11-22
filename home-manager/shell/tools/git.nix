{ pkgs, ... }: {
  home.packages = with pkgs; [
    commitizen
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
      userName = "jacbart";
      userEmail = "jacbart@gmail.com";
      # delta = {
      #     enable = true;
      #     options = {
      #         features = "decorations";
      #         navigate = true;
      #         side-by-side = true;
      #     };
      # };
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        cc = "cz commit";
        ck = "cz check";
        cl = "cz changelog";
        cv = "cz version";
      };
      extraConfig = {
        core = {
          editor = "hx";
          sshCommand = "ssh -i ~/.ssh/id_git -i ~/.ssh/id_git_sk";
        };
        url = {
          "git@github.com:jacbart" = {
            insteadOf = "https://github.com/jacbart";
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
      };
      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
  };
}
