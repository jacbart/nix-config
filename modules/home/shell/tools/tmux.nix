{
  pkgs,
  lib,
  hostname,
  ...
}:
let
  # Per-host gruvbox variant (egel/tmux-gruvbox): dark | dark256 | light | light256
  hostGruvbox =
    {
      boojum = "dark256";
      cork = "dark";
      ash = "light256";
      unicron = "light";
      sycamore = "dark256";
      oak = "dark";
      mesquite = "light256";
      maple = "light";
      jackjrny = "dark256";
      iso = "dark256";
    }
    .${hostname} or "dark256";

  # Distinct tmux colours (palette 0–255) for borders / current window — add new hosts here.
  hostAccent =
    {
      boojum = "colour33";
      cork = "colour166";
      ash = "colour76";
      unicron = "colour45";
      sycamore = "colour135";
      oak = "colour208";
      mesquite = "colour61";
      maple = "colour9";
      jackjrny = "colour214";
      iso = "colour12";
    }
    .${hostname} or "colour33";

  gitu = (
    pkgs.unstable.gitu.overrideAttrs (old: {
      doCheck = false;
    })
  );

  # Pin plugins in the Nix closure (no TPM / no prefix+I). Same upstreams as nixpkgs tmuxPlugins.
  tmuxPlugins = pkgs.tmuxPlugins;

  sesh = pkgs.unstable.sesh;

  # PATH for fzf-tmux reload hooks + tmux kill-session (see https://github.com/joshmedeski/sesh)
  seshFzf = pkgs.writeShellScript "tmux-sesh-fzf" ''
    export PATH="${
      lib.makeBinPath [
        sesh
        pkgs.fzf
        pkgs.fd
        pkgs.tmux
      ]
    }:$PATH"
    sesh connect "$(sesh list --icons | fzf-tmux -p 80%,70% \
      --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
      --preview-window 'right:55%' \
      --preview 'sesh preview {}')"
  '';

  # sesh window picker (https://github.com/joshmedeski/sesh — tmux + fzf)
  seshWindowFzf = pkgs.writeShellScript "tmux-sesh-window-fzf" ''
    export PATH="${
      lib.makeBinPath [
        sesh
        pkgs.fzf
      ]
    }:$PATH"
    choice=$(sesh window | fzf-tmux -p 60%,50% --prompt '🪟  ') || exit 0
    exec sesh window "$choice"
  '';

  # sesh connect --root from active pane cwd (replaces default prefix+9 = select-window -t 9)
  seshRoot = pkgs.writeShellScript "tmux-sesh-root" ''
    export PATH="${lib.makeBinPath [ sesh ]}:$PATH"
    pane=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null) || exit 1
    cd "$pane" || exit 1
    exec sesh connect --root "$(pwd)"
  '';
in
{
  home = {
    # Install tmux
    packages = [
      pkgs.tmux
      sesh
      gitu # TUI Git client inspired by Magit
    ];

    # sesh — https://github.com/joshmedeski/sesh (starter only; force=false keeps your local edits on switch)
    file.".config/sesh/sesh.toml" = {
      force = false;
      text = ''
        #:schema https://github.com/joshmedeski/sesh/raw/main/sesh.schema.json

        # sesh reads this from $XDG_CONFIG_HOME/sesh/sesh.toml (here: ~/.config/sesh/sesh.toml).

        # Hide sessions from pickers / lists.
        blacklist = []

        # How many trailing path segments to use for auto session names (default 1).
        # dir_length = 2

        # Order of session types in lists: tmux, config, tmuxinator, zoxide.
        # sort_order = [ "tmux", "config", "tmuxinator", "zoxide" ]

        # Example fixed session (uncomment and edit):
        # [[session]]
        # name = "dotfiles"
        # path = "~/workspace/personal/nix-config"

        # Example pattern for many repos (uncomment and edit):
        # [[wildcard]]
        # pattern = "~/workspace/*"
        # startup_command = "nvim"

        # Default preview in pickers (paths from Nix store at generation time).
        [default_session]
        preview_command = "${pkgs.eza}/bin/eza --all --git --icons --color=always {}"
      '';
    };

    # Tmux home dir config file
    file.".tmux.conf".text = ''
      set -sg escape-time 10

      # Plugins (from nixpkgs; no TPM — avoids translucent/odd status from mixed load order + @plugin)
      run '${tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux'
      set -g @tmux-gruvbox '${hostGruvbox}'
      set -g @tmux-gruvbox-statusbar-alpha 'false'
      run '${tmuxPlugins.gruvbox}/share/tmux-plugins/gruvbox/gruvbox-tpm.tmux'
      run '${tmuxPlugins.better-mouse-mode}/share/tmux-plugins/better-mouse-mode/scroll_copy_mode.tmux'

      # Window Splitting
      unbind %
      bind | split-window -h -f -c '#{pane_current_path}'
      bind \\ split-window -h -c '#{pane_current_path}'
      bind _ split-window -v -f -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      set-option -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g mouse on

      # sesh (https://github.com/joshmedeski/sesh): pairs with prefix+L (sesh last); no quit on last session close
      set -g detach-on-destroy off
      bind-key x kill-pane

      set-option -g status-keys vi
      set-window-option -g mode-keys vi

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

      # remote session
      unbind C-r
      bind-key C-r command-prompt "new-session -s %1 ssh %1 \; set-option default-command \"ssh %1\""

      # sesh: zoxide-backed session manager (needs zoxide in shell — programs.zoxide)
      unbind s
      bind-key K display-popup -h 90% -w 50% -E "${sesh}/bin/sesh picker -i"
      bind-key s run-shell "${seshFzf}"
      bind-key L run-shell "${sesh}/bin/sesh last"
      bind-key W run-shell "${seshWindowFzf}"
      unbind 9
      bind-key 9 run-shell "${seshRoot}"

      # Journal
      unbind j
      bind-key j display-popup -y 55% -h 75% -E "tmux new-session -A -s 'Journal' 'fern'"

      # Newsboat
      unbind N
      bind-key N display-popup -y 55% -h 75% -E "tmux new-session -A -s 'Newsboat' 'newsboat'"

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

      # Per-host cue: active pane border only (leave status line to gruvbox — avoids clashing colours)
      set -g pane-active-border-style 'fg=${hostAccent},bold'
    '';
  };
}
