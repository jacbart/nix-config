{ pkgs, ... }: {
  imports = [
    ./tools # cli/tui tools or services
    ./zsh.nix # zsh config
  ];

  home.packages = with pkgs; [
    scripts.journal
  ];

  home.file.".ssh/config".text = ''
    Host boojum
        HostName boojum.meep.sh
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host ash
        HostName ash.meep.sh
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host maple
        HostName maple.meep.sh
        User ratatoskr
        IdentityFile ~/.ssh/id_ratatoskr
  '';
}
