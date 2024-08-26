{ pkgs, ... }: {
    imports = [
        ./bottom.nix
        ./broot.nix
        ./eza.nix
        ./git.nix
        ./helix.nix
        ./neofetch.nix
        ./starship.nix
        ./tmux.nix
        ./zoxide.nix
    ];

    home = {
        packages = with pkgs; [
            angle-grinder
            bitwarden-cli
            dogdns
            fastfetch
            fd
            fzf
            htmlq
            # hyperfine
            netcat
            # nurl
            nix-melt
            mprocs
            procs
            ripgrep
            sd
            xh
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
