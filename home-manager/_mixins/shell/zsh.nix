{ config, pkgs, lib, ... }: let
  inherit (pkgs.stdenv) isLinux isDarwin;
  modPath = [
    "$PATH"
    "$HOME/bin"
  ] ++ lib.optional (isDarwin) "/opt/homebrew/bin";
  modPathStr = lib.strings.concatMapStrings (path: path + ":") modPath;
in {
    home.packages = with pkgs; [
      perl # Required for zplug
    ] ++ lib.optional (isLinux) unstable.tlrc;

    programs.zsh = {
      enable = true;
      sessionVariables = {
        STOW_DIR = "$HOME/.dotfiles/stowpkgs";
        ZSHDATADIR = "${config.xdg.dataHome}/zsh";
        PATH = "${modPathStr}";
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
        st = "stow -v -t $HOME";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
        rebuild-all = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config && home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-home = "home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config";
        rebuild-lock = "pushd $HOME/workspace/personal/nix-config && nix flake update && popd";
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "plugins/fzf"; tags = [ "from:oh-my-zsh" ]; }
          { name = "plugins/git"; tags = [ "from:oh-my-zsh" ]; }
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
      initExtra = ''
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff5f00"
        bindkey '^E' autosuggest-accept
        bindkey '^ ' forward-word
      '';
    };
}
