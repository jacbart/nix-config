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
      extraConfig = ''
        let carapace_completer = {|spans|
          carapace $spans.0 nushell $spans | from json
        }
        $env.config = {
          show_banner: false,
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true           # set to false to prevent auto-selecting completions
            partial: true         # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100
              completer: $carapace_completer # check 'carapace_completer'
            }
          }
        }
      '';
    };
  };
}
