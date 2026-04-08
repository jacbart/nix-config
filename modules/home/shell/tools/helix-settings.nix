{
  theme = "gruvbox_dark_hard";
  keys.normal = {
    # go back if select too many lines with x
    X = "select_line_above";
    # forward in undo history
    L = ":later";
    # code actions
    ";" = {
      B = ":pipe base64 -w 0";
      D = ":pipe base64 -d";
      c = ":pipe view_cert";
      C = ":pipe base64 -d | view_cert";
      y = ":yank-diagnostic";
      r = ":reload";
      R = [
        ":lsp-stop"
        ":config-reload"
        ":reload-all"
        ":lsp-restart"
      ];
      z = ":pipe zsh";
    };
    # git shortcuts
    G = {
      d = ":! git diff";
      D = ":! git diff --cached";
    };
    "{" = [
      "goto_prev_paragraph"
      "collapse_selection"
    ];
    "}" = [
      "goto_next_paragraph"
      "collapse_selection"
    ];
    space = {
      B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
      i = ":toggle lsp.display-inlay-hints";
      W = ":write-all";
      J = ":insert-output echo \"# $(date '+%%Y-%%m-%%d')\"";
      esc = [
        "collapse_selection"
        "keep_primary_selection"
      ];
    };
    C-h = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
    C-l = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
    C-j = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
    C-k = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
    C-left = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
    C-right = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
    C-down = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
    C-up = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
  };
  keys.insert = {
    C-h = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
    C-l = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
    C-j = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
    C-k = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
    C-left = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
    C-right = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
    C-down = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
    C-up = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
  };

  editor = {
    shell = [
      "zsh"
      "-c"
    ];
    line-number = "absolute";
    mouse = true;
    scroll-lines = 1;
    popup-border = "all";
    color-modes = true;
    auto-pairs = true;
    # bufferline = "always";
    rulers = [ 100 ];
    auto-completion = true;
    path-completion = true;
    auto-format = true;
    end-of-line-diagnostics = "hint";
    inline-diagnostics = {
      cursor-line = "warning";
    };
    smart-tab = {
      enable = false;
      supersede-menu = false;
    };
    gutters.layout = [
      "diff"
      "diagnostics"
      "line-numbers"
      "spacer"
    ];
    gutters.line-numbers.min-width = 1;
    statusline = {
      left = [
        "mode"
        "spinner"
      ];
      center = [ "file-name" ];
      right = [
        "diagnostics"
        "selections"
        "position"
        "file-encoding"
        "file-line-ending"
        "file-type"
      ];
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
}
