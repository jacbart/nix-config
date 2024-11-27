{ pkgs, ... }: {
  imports = [ ./tools/starship.nix ];
  programs = {
    nushell = {
      enable = true;
      package = pkgs.unstable.nushell;
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        less = "bat --paging=always";
        more = "bat --paging=always";
        gs = "git status";
        ga = "git add";
        gcm = "git commit -m";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
        rebuild-all = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config && home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-home = "home-manager switch -b backup --flake $HOME/workspace/personal/nix-config";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config";
        rebuild-lock = "pushd $HOME/workspace/personal/nix-config && nix flake update && popd";
      };
    };

    carapace = {
      enable = true;
      package = pkgs.unstable.carapace;
      enableNushellIntegration = true;
    };
  };
}
