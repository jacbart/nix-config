_: {
  programs.zsh.shellAliases = {
    nix-gc = "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
    rebuild-all = "sudo nixos-rebuild switch --flake $HOME/decepticonix && home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
    rebuild-home = "home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
    rebuild-host = "sudo nixos-rebuild switch --flake $HOME/decepticonix";
    rebuild-lock = "pushd $HOME/decepticonix && nix flake update && popd";
  };
}
