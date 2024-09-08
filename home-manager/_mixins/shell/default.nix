{ config, username, ... }:
# let
    # helper function for generating a shell (minimal, server, desktop)
    # mkDotenv = { type ? "minimal" }: {
        
    # };
# in
{
    imports = [
        ./tools # cli/tui tools or services
        ./scripts # shellApplications
        ./zsh.nix # zsh config
    ];

    home.file.".ssh/config".text = ''
        Host boojum
            HostName boojum.meep.sh
            User meep
            Port 22
            IdentityFile ~/.ssh/id_ratatoskr

        Host maple
            HostName maple.meep.sh
            User ratatoskr
            Port 22
            IdentityFile ~/.ssh/id_ratatoskr
    '';

    # systemd.tmpfiles.rules = [
    #     "f ${config.home.homeDirectory} 0600 ${username}"
    # ];
}
