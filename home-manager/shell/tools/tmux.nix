{ pkgs, ... }: {
  home = {
    # Install tmux
    packages = [
      pkgs.tmux
    ];

    # Fetch the tmux plugin manager (tpm) and place it in the ~/.tmux/plugins/tpm directory
    file.".tmux/plugins/tpm".source = builtins.fetchGit {
      url = "https://github.com/tmux-plugins/tpm";
      rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    };

    # Tmux home dir config file
    file.".tmux.conf".text = ''
      set -g escape-time 50

      # List of plugins
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'egel/tmux-gruvbox'
      set -g @plugin 'nhdaly/tmux-better-mouse-mode'

      # Smart pane switching with awareness of vim splits
      is_hx='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|hx?)(diff)?$"'
      bind -n C-h if-shell "$is_hx" "send-keys C-h" "select-pane -L"
      bind -n C-u if-shell "$is_hx" "send-keys C-u" "select-pane -U"
      bind -n C-l if-shell "$is_hx" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "$is_hx" "send-keys C-\\" "select-pane -l"

      # Window Splitting
      unbind %
      bind | split-window -h -f -c '#{pane_current_path}'
      bind \\ split-window -h -c '#{pane_current_path}'
      bind _ split-window -v -f -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      # set -g default-terminal "xterm-256color"
      set -g default-terminal "xterm-ghostty"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g mouse on

      set -g status-keys vi

      # Theming
      set -g @tmux-gruvbox 'dark256'
      set -g @tmux-gruvbox-statusbar-alpha 'true'

      # Don't exit copy mode when mouse drags
      unbind -T copy-mode-vi MouseDragEnd1Pane
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # Pane titles
      unbind t
      bind t setw pane-border-status
      set -g pane-border-format "#{pane_title}"
      # Rename pane
      unbind T
      bind T command-prompt -p "(rename-pane)" -I "#T" "select-pane -T '%%'"

      # Journal
      unbind e
      bind e display-popup -E "tmux new-session -A -s 'Journal' 'cd $HOME/workspace/journal && hx $(date "+%Y-%m-%d").md'"
      # Simple shell popup
      unbind P
      bind P display-popup -E "tmux new-session -A -s 'Shell' '$SHELL'"
      # Broot popup
      unbind f
      bind f display-popup -y 45 -h 80% -E -d '#{pane_current_path}' "tmux new-session -A -s 'Files' 'broot --no-tree'"
      # Broot new window
      unbind F
      bind F new-window -n "broot" -c "#{pane_current_path}" "broot"

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
