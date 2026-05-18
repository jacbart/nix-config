{
  pkgs,
  platform,
  lib,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  home.packages =
    with pkgs;
    [
      scripts.journal
      inputs.nix-diff.packages.${platform}.default
    ]
    ++ lib.optional isLinux pkgs.pax-utils;

  home.file.".ssh/config".text = ''
    Host ash
        HostName ash
        User meep
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host boojum
        HostName boojum
        User meep
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host cork
        HostName cork
        User meep
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host jackjrny
        HostName jackjrny
        User jackbartlett
        SetEnv TERM=xterm-256color
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host maple
        HostName maple
        User ratatoskr
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host mesquite
        HostName mesquite
        User ratatoskr
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host oak
        HostName oak
        User root
        SetEnv TERM=xterm-256color
        Port 3048
        IdentityFile ~/.ssh/id_do
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host sycamore
        HostName sycamore
        User jackbartlett
        SetEnv TERM=xterm-256color
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host unicron
        HostName unicron
        User jack
        SetEnv TERM=xterm-256color
        IdentityFile ~/.ssh/id_ratatoskr
        ControlMaster auto
        ControlPath ~/.ssh/mux-%r@%h:%p
        ControlPersist 10

    Host cgit.bbl.systems
        User git
        IdentityFile ~/.ssh/id_ratatoskr
        IdentitiesOnly yes
  '';
}
