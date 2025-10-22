{ pkgs, ... }:
{
  home = {
    # Install tmux
    packages = [
      pkgs.tmux
      pkgs.gitu # TUI Git client inspired by Magit
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

      set-option -g default-terminal "xterm-256color"
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
      unbind j
      bind-key j display-popup -y 55% -h 75% -E "tmux new-session -A -s 'Journal' 'mkdir -p $HOME/workspace/journal && cd $HOME/workspace/journal && hx $(date "+%Y-%m-%d").md'"

      # Simple shell popup
      unbind e
      bind-key e display-popup -y 55% -h 75% -E "tmux new-session -A -s 'Shell' '$SHELL'"

      # gitu popup
      unbind g
      bind-key g display-popup -y 55% -h 75% -d '#{pane_current_path}' -E "tmux new-session -A -s 'git' 'gitu'"

      # Broot popup
      unbind f
      bind-key f display-popup -y 55% -h 75% -E -d '#{pane_current_path}' "tmux new-session -A -s 'Files' 'broot --no-tree'"

      # Broot new window
      unbind F
      bind-key F new-window -n "broot" -c "#{pane_current_path}" "broot"

      is_hx="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?hx?x?|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_hx" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_hx" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_hx" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_hx" 'send-keys C-l'  'select-pane -R'

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
