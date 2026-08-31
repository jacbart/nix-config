# StevenBlack unified hosts sinkhole for macOS (ad/malware blocking).
#
# NixOS hosts get this via networking.stevenblack (modules/nixos/core.nix);
# nix-darwin has no equivalent option, so we install the same merged hosts
# file to /etc/hosts declaratively. nix-darwin backs up the stock /etc/hosts
# on first activation.
#
# Pinned by hash (supply chain): upstream `master` moves daily, so this only
# ever changes when the sha256 below is bumped deliberately. Refresh with
# `task update:hosts` and paste the new hash.
{ ... }:
{
  flake.modules.darwin.stevenblack =
    { pkgs, ... }:
    let
      stevenblackHosts = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        sha256 = "1i3n5184x6yrbfbapqd6zdyx5z59sxbbdav97k3gaakd9800vb1p";
      };
    in
    {
      environment.etc."hosts".source = stevenblackHosts;
    };
}
