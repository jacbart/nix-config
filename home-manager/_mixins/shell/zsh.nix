{ config, pkgs, ... }: {
    home.packages = with pkgs; [
        perl # Required for zplug
    ];

    programs.zsh = {
      enable = true;
      shellAliases = {
        cat = "bat --paging=never --style=plain";
        htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        hm = "home-manager";
        less = "bat --paging=always";
        more = "bat --paging=always";
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        kc = "kubectl";
        nc = "ncat";
        t = "tmux";
        j = "z";
        gs = "git status";
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
          { name = "plugins/fzf"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/z"; tags = [ from:oh-my-zsh ]; }
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
        for file in $ZSHDATADIR/functions/os/*; do source $file; done
        for file in $ZSHDATADIR/functions/misc/*; do source $file; done
      '';
    };
}