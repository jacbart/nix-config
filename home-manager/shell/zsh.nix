{ config
, pkgs
, lib
, ...
}:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  modPath =
    [
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

  home.packages = with pkgs;
    [
      mdbook # markdown books
      uv
      ruff # python scripts
      perl # Required for zplug
      htmlq # parser for html
      unstable.nh # nix helper cli
    ]
    ++ lib.optional isLinux unstable.tlrc;

  programs.zsh = {
    enable = true;
    sessionVariables = {
      ZSHDATADIR = "${config.xdg.dataHome}/zsh";
      PATH = "${modPathStr}";
      TERM = "xterm-ghostty";
    };
    shellAliases = {
      cd = "z";
      j = "z";
      ls = "eza";
      ll = "eza --long";
      la = "eza --long --all";
      tree = "eza --long --tree --level=3";
      cat = "bat --paging=never --style=plain";
      hm = "home-manager";
      less = "bat --paging=always";
      more = "bat --paging=always";
      top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      gs = "git status";
      ga = "git add";
      gcm = "git commit -m";
      clock = "while :; do printf '\r%s ' \"$(date +%r)\"; sleep 1 ; done";
      nix-gc = lib.mkDefault "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
      rebuild-all = lib.mkDefault "nh os switch $HOME/workspace/personal/nix-config --ask && nh home switch -b backup $HOME/workspace/personal/nix-config --ask";
      rebuild-home = lib.mkDefault "nh home switch -b backup $HOME/workspace/personal/nix-config --ask";
      rebuild-host = lib.mkDefault "nh os switch $HOME/workspace/personal/nix-config --ask";
      rebuild-lock = lib.mkDefault "pushd $HOME/workspace/personal/nix-config && nix flake update && popd";
    };
    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/fzf";
          tags = [ "from:oh-my-zsh" ];
        }
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zsh-users/zsh-completions"; }
      ];
    };
    history = {
      size = 100000;
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initContent = ''
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff5f00"
      bindkey '^E' autosuggest-accept
      bindkey '^ ' forward-word
    '';
  };
}
