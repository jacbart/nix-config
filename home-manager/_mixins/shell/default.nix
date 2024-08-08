{ config, pkgs, ... }: let
    inherit (pkgs.stdenv) isDarwin;
in {
    imports = [
        ./tools
        ./plugins
        ./scripts
        ./zsh.nix
    ];

    home = {
        packages = with pkgs; [
            ripgrep
            fd
        ];
        sessionVariables = {
            MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
            BREW_PATH = if isDarwin then "/opt/homebrew/bin" else "";
            SCRIPT_PATH = "${config.xdg.dataHome}/zsh/scripts";
            PATH = if isDarwin then "$PATH:$BREW_PATH:$SCRIPT_PATH" else "$PATH:$SCRIPT_PATH";
            STOW_DIR = "$HOME/.dotfiles/stowpkgs";
            ZSHDATADIR = "${config.xdg.dataHome}/zsh";
        };
    };

    # default shell programs
    programs = {
        bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [
                batwatch
                prettybat
            ];
        };
        dircolors = {
            enable = true;
            enableZshIntegration = true;
        };
        direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv = {
            enable = true;
            };
        };
        fzf = {
            enable = true;
            enableZshIntegration = true;
        };
        home-manager.enable = true;
        info.enable = true;
        jq.enable = true;
    };
}