{ pkgs, ... }: {
  imports = [ ./tools/starship.nix ];
  programs = {
    nushell = {
      enable = true;
      package = pkgs.nushell;
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        less = "bat --paging=always";
        more = "bat --paging=always";
        gs = "git status";
        ga = "git add";
        gd = "git diff";
        gcm = "git commit -m";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 10d; nix-collect-garbage --delete-older-than 10d";
        rebuild-all = "sudo nixos-rebuild switch --flake $\"($env.HOME)/workspace/personal/nix-config\"; home-manager switch -b backup --flake $\"($env.HOME)/workspace/personal/nix-config\"";
        rebuild-home = "home-manager switch -b backup --flake $\"($env.HOME)/workspace/personal/nix-config\"";
        rebuild-host = "sudo nixos-rebuild switch --flake $\"($env.HOME)/workspace/personal/nix-config\"";
      };
    };
  };
}
