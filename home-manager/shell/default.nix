{ pkgs
, lib
, ...
}:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [
    ./tools # cli/tui tools or services
    ./zsh.nix # zsh config
    ./nushell.nix # nu shell config
  ];

  programs.carapace = {
    enable = true;
    package = pkgs.unstable.carapace;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  home.packages = with pkgs;
    [
      scripts.journal
    ]
    ++ lib.optional isLinux pkgs.pax-utils;

  home.file.".ssh/config".text = ''
    Host boojum
        HostName boojum
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host ash
        HostName ash
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host maple
        HostName maple
        User ratatoskr
        IdentityFile ~/.ssh/id_ratatoskr

    Host mac
        HostName jackjrny
        User jackbartlett
  '';
}
