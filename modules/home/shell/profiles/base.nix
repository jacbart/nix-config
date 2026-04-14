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
        IdentityFile ~/.ssh/id_ratatoskr

    Host boojum
        HostName boojum
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host cork
        HostName cork
        User meep
        IdentityFile ~/.ssh/id_ratatoskr

    Host jackjrny
        HostName jackjrny
        User jackbartlett

    Host maple
        HostName maple
        User ratatoskr
        IdentityFile ~/.ssh/id_ratatoskr

    Host mesquite
        HostName mesquite
        User ratatoskr
        IdentityFile ~/.ssh/id_ratatoskr

    Host oak
        HostName oak
        User root
        Port 3048
        IdentityFile ~/.ssh/id_do

    Host sycamore
        HostName sycamore
        User jackbartlett

    Host unicron
        HostName unicron
        User jack
        IdentityFile ~/.ssh/id_ratatoskr
  '';
}
