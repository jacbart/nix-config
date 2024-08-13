{ pkgs, ... }: let
    # helper function for generating a shell (minimal, server, desktop)
    mkDotenv = { type ? "minimal" }: {
        
    };
in {
    imports = [
        ./tools # cli/tui tools or services
        ./plugins # shell extenstions ie functions or alias'
        ./scripts # scripts auto added to PATH
        ./zsh.nix # zsh config
    ];

    home = {
        packages = with pkgs; [
            ripgrep
            fd
            netcat
        ];
        sessionVariables = {
            MANROFFOPT = "-c";
            MANPAGER = "sh -c 'col -bx | bat -plman'";
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
            nix-direnv.enable = true;
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
