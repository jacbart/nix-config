{
  config,
  pkgs,
  lib,
  # inputs,
  ...
}:
let
  # ff = inputs.ff.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # trees = inputs.trees.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # rest = inputs.rest.packages.${pkgs.stdenv.hostPlatform.system}.default;
  inherit (pkgs.stdenv) isLinux isDarwin;
  modPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ]
  ++ lib.optional isDarwin "/opt/homebrew/bin"
  ++ [
    "$PATH"
  ];
  modPathStr = lib.strings.concatMapStrings (path: path + ":") modPath;
in
{
  imports = [ ./tools/starship.nix ];

  home.packages =
    with pkgs;
    [
      mdbook # markdown books
      uv # python package/dep/runtime manager
      perl # Required for zplug
      htmlq # parser for html
      unstable.nh # nix helper cli
      # rest # rest easy
      stu # TUI explorer application for Amazon S3
      # trees # git worktrees simplified
      # ff # not so percise search
    ]
    ++ lib.optional isLinux unstable.tlrc;

  programs.zsh = {
    enable = true;
    sessionVariables = {
      ZSHDATADIR = "${config.xdg.dataHome}/zsh";
      PATH = "${modPathStr}";
      TERM = "xterm-256color";
    };
    shellAliases = {
      cd = "z";
      j = "z";
      ls = "eza";
      ll = "eza --long";
      la = "eza --long --all";
      tree = "eza --long --tree --level=3";
      cat = "bat --paging=never --style=plain";
      vc = "view_cert";
      oc = "opencode --agent plan .";
      hm = "home-manager";
      less = "bat --paging=always";
      lm = "if [ $(systemctl --user is-active lan-mouse) = \"inactive\" ]; then systemctl --user start lan-mouse && echo active; else systemctl --user stop lan-mouse && echo inactive; fi";
      more = "bat --paging=always";
      secure = "eval $(ssh-agent -s -t 3600 -k) && ssh-add ~/.ssh/id_git";
      hist = "fc -RI";
      g = "gitu";
      gd = "git diff | delta";
      gdc = "git diff --cached | delta";
      gs = "git status";
      ga = "git add";
      gcm = "git commit -m";
      clock = "while :; do printf '\r%s ' \"$(date +%r)\"; sleep 1 ; done";
      nix-gc = lib.mkDefault "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
      rebuild-home = lib.mkDefault "nh home switch -b backup $HOME/workspace/personal/nix-config --ask";
      rebuild-host = lib.mkDefault "nh os switch $HOME/workspace/personal/nix-config --ask";
    };
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "multirious/zsh-helix-mode"; }
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zsh-users/zsh-completions"; }
        {
          name = "plugins/fzf";
          tags = [ "from:oh-my-zsh" ];
        }
      ];
    };
    history = {
      size = 500000;
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    setOptions = [
      "INC_APPEND_HISTORY"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
    ];
    initContent = ''
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M hxins 'v' edit-command-line
      zstyle ':completion:*' matcher-list "" \
        'm:{a-z\-}={A-Z\_}' \
        'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
        'r:|?=** m:{a-z\-}={A-Z\_}'
      zstyle ':completion:*' menu select
      ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
        zhm_history_prev
        zhm_history_next
        zhm_prompt_accept
        zhm_accept
        zhm_accept_or_insert_newline
      )
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(
        zhm_move_right
        zhm_clear_selection_move_right
      )
      ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
        zhm_move_next_word_start
        zhm_move_next_word_end
      )
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff5f00"
      zhm-add-update-region-highlight-hook
      zhm_wrap_widget fzf-completion zhm_fzf_completion
      zhm_wrap_widget fzf-history-widget zhm_fzf_history_widget 
      bindkey '^I' zhm_fzf_completion
      bindkey '^R' zhm_fzf_history_widget
      bindkey '^E' autosuggest-accept
      bindkey '^ ' forward-word
    '';
  };
}
