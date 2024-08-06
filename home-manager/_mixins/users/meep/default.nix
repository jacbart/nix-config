{ config, lib, pkgs, ... }: {
  imports = [
    ./starship.nix
  ];
  home = {
    file = {
      # add broot config
      "${config.xdg.configHome}/broot/conf.hjson".text = builtins.readFile ./broot/conf.hjson;
      "${config.xdg.configHome}/broot/verbs.hjson".text = builtins.readFile ./broot/verbs.hjson;
      "${config.xdg.configHome}/broot/skins/dark-gruvbox.hjson".text = builtins.readFile ./broot/skins/dark-gruvbox.hjson;
      "${config.xdg.configHome}/broot/skins/white.hjson".text = builtins.readFile ./broot/skins/white.hjson;
    };
    packages = with pkgs; [
      neofetch
      ripgrep
      fzf
      fd
      perl
    ];
    sessionVariables = {
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
    };
  };

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batwatch
        prettybat
      ];
    };
    bottom = {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
    broot = {
      enable = true;
      enableZshIntegration = true;
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        cat = "bat --paging=never --style=plain";
        htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        ip = "ip --color --brief";
        less = "bat --paging=always";
        more = "bat --paging=always";
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        kc = "kubectl";
        nc = "ncat";
        t = "tmux";
        j = "z";
        gs = "git status";
        ll = "ls -lh";
        la = "ls -lah";
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "plugins/fzf"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/tmux"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/z"; tags = [ from:oh-my-zsh ]; }
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-completions"; }
        ];
      };
      history = {
        size = 100000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      initExtra = ''
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff5f00"
        bindkey '^E' autosuggest-accept
        bindkey '^ ' forward-word
      '';
    };
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "hx";
        git_protocol = "ssh";
        prompt = "disable";
      };
    };
    git = {
      enable = true;
      userName = "jacbart";
      userEmail = "jacbart@gmail.com";
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };
      };
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
          sshCommand = "ssh -i ~/.ssh/id_git";
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
    gpg.enable = true;
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
