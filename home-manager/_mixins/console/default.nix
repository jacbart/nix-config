{ config, lib, pkgs, ... }: {
  home = {
    file = {
      "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ./neofetch.conf;
    };
    packages = with pkgs; [
      neofetch
      ripgrep
      fzf
    ];
    sessionVariables = {
      EDITOR = "hx";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs = {
    # atuin = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   flags = [
    #     "--disable-up-arrow"
    #   ];
    #   package = pkgs.unstable.atuin;
    #   settings = {
    #     auto_sync = true;
    #     dialect = "us";
    #     show_preview = true;
    #     style = "compact";
    #     sync_frequency = "1h";
    #     sync_address = "https://api.atuin.sh";
    #     update_check = false;
    #   };
    # };
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
    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    exa = {
      enable = true;
      enableAliases = true;
      icons = true;
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
        tree = "exa --tree";
      };
    };
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "hx";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      enable = true;
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
      };
      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
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
    helix = {
      enable = true;
      languages = {
        language = [{
          name = "hcl";
          file-type = ["tf", "tfvars", "hcl", "koi"];
          auto-format = true;
        }];
      };
      settings = {
        theme = "ayu_dark"
        editor = {
          shell = ["zsh", "-c"];
          line-number = "absolute";
          mouse = true;
          color-modes = true;
          auto-pairs = true;
          bufferline = "multiple";
          auto-completion = true;
          auto-format = true;
          statusline {
            left = ["mode", "spinner"];
            center = ["file-name"];
            right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"];
            separator = "│";
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker = {
            hidden = false;
            git-ignore = true;
          };
          whitespace.render = {
            space = "none";
            tab = "none";
            newline = "none";
          };
          whitespace.characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
            tabpad = "·";
          };
          lsp.display-messages = true;
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
        };
      };
    };
    programs.starship = {
      enable = true;
      # Configuration written to ~/.config/starship.toml
      settings = {
        format = "$username$hostname$sudo$directory$git_branch$git_state$git_status$fill$helm$kubernetes$golang$rust$terraform$nix_shell$jobs$cmd_duration$time$line_break$character";
        command_timeout = 1000;

        sudo = {
          disabled = true;
          style = "bold green";
          symbol = "";
          format = "[as $symbol]($style) ";
        };

        username = {
          style_user = "white dimmed";
          style_root = "red bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = false;
        };

        hostname = {
          ssh_only = true;
          ssh_symbol = " ";
          format = "@[$hostname]($style) ";
          style = "green bold dimmed";
        };

        fill = {
          symbol = "-";
          style = "bright-black";
        };

        directory = {
          style = "blue";
          home_symbol = "~";
          truncation_symbol = ".../";
          truncation_length = 5;
        };

        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
          vicmd_symbol = "[❮](green)";
        };

        git_branch = {
          format = "[$branch]($style) ";
          style = "green";
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
          style = "cyan";
        };

        git_state = {
          format = "([$state( $progress_current/$progress_total)]($style)) ";
          style = "bright-black";
        };

        golang = {
          format = " [$symbol$version]($style)";
          symbol = " ";
        };
        
        rust = {
          disabled = false;
        };

        nix_shell = {
          disabled = false;
          impure_msg = "[impure shell](bold red)";
          pure_msg = "[pure shell](bold green)";
          format = " via [$symbol$state( \($name\))](bold blue)";
        };

        terraform = {
          format = " [$symbol$version $workspace]($style)";
        };

        helm = {
          format = " via [⎈ $version](bold white) ";
        };

        kubernetes = {
          format = "";
          disabled = true;
        };
        
        jobs = {
          disabled = false;
        };

        cmd_duration = {
          format = " [$duration]($style)";
          style = "yellow";
        };
        time = {
          disabled = false;
          use_12hr = false;
          format = " at [$time]($style)";
          utc_time_offset = "local";
        };
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "curses";
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
