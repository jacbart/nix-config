{ pkgs, ... }: let
    # helper function for generating a shell (minimal, server, desktop)
    mkDotenv = { type ? "minimal" }: {
        
    };
in {
    imports = [
        ./tools # cli/tui tools or services
        ./scripts # shellApplications
        ./zsh.nix # zsh config
    ];
}
