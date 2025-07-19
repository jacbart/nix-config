{ pkgs, ... }:
{
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
      set -sg escape-time 10

      # List of plugins
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'egel/tmux-gruvbox'
      set -g @plugin 'nhdaly/tmux-better-mouse-mode'

      # Window Splitting
      unbind %
      bind | split-window -h -f -c '#{pane_current_path}'
      bind \\ split-window -h -c '#{pane_current_path}'
      bind _ split-window -v -f -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      # set-option -g default-terminal "xterm-256color"
      set-option -g default-terminal "xterm-ghostty"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g mouse on

      set-option -g status-keys vi
      set-window-option -g mode-keys vi

      # Theming
      set -g @tmux-gruvbox 'dark256'
      set -g @tmux-gruvbox-statusbar-alpha 'true'

      # Don't exit copy mode when mouse drags
      unbind -T copy-mode-vi MouseDragEnd1Pane
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # scroll speed
      unbind -T copy-mode-vi WheelUpPane
      unbind -T copy-mode-vi WheelDownPane
      bind-key -T copy-mode-vi WheelUpPane send-keys -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down

      # Pane titles
      unbind t
      bind-key t setw pane-border-status
      set-option -g pane-border-format "#{pane_title}"

      # Rename pane
      unbind T
      bind-key T command-prompt -p "(rename-pane)" -I "#T" "select-pane -T '%%'"

      # Journal
      unbind e
      bind-key e display-popup -E "tmux new-session -A -s 'Journal' 'cd $HOME/workspace/journal && hx $(date "+%Y-%m-%d").md'"

      # Simple shell popup
      unbind P
      bind-key P display-popup -E "tmux new-session -A -s 'Shell' '$SHELL'"

      # Broot popup
      unbind f
      bind-key f display-popup -y 45 -h 80% -E -d '#{pane_current_path}' "tmux new-session -A -s 'Files' 'broot --no-tree'"

      # Broot new window
      unbind F
      bind-key F new-window -n "broot" -c "#{pane_current_path}" "broot"

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
