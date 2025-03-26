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
      extraConfig = {
        user = {
          name = "jacbart";
          email = "jacbart@gmail.com";
          signingkey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIF4nyZ9WdHRf6yy6IlB/qJbNLIf3Sp9umUjm1pHhIAvAAAABHNzaDo= jacbart@gmail.com";
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
          sshCommand = "ssh -i ~/.ssh/id_git_sk -i ~/.ssh/id_git";
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
        gpg.format = "ssh";
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
