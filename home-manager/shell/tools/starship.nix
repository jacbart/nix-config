_: {
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
}
