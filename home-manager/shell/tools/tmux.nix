{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ tmux ];

    # Fetch the tmux plugin manager (tpm) and place it in the ~/.tmux/plugins/tpm directory
    file.".tmux/plugins/tpm".source = builtins.fetchGit {
      url = "https://github.com/tmux-plugins/tpm";
      rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    };

    file.".tmux.conf".text = ''
      set -g escape-time 50

      # List of plugins
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'egel/tmux-gruvbox'
      set -g @plugin 'nhdaly/tmux-better-mouse-mode'

      # Smart pane switching with awareness of vim splits
      is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?)(diff)?$"'
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-u if-shell "$is_vim" "send-keys C-u" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

      # Window Splitting
      unbind %
      bind | split-window -h -f -c '#{pane_current_path}'
      bind \\ split-window -h -c '#{pane_current_path}'
      bind _ split-window -v -f -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      set -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g mouse on

      set -g status-keys vi

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

      bind-key e run-shell 'tmux popup -E "hx $HOME/workspace/journal/$(date "+%Y-%m-%d").md"'

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
