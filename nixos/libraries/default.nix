{
  pkgs,
  lib,
  ...
}:
let
  isX86_64 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
  # programs.nix-ld.dev.libraries =
  programs.nix-ld.libraries = lib.optional isX86_64 pkgs.stdenv.cc.cc.lib;
}
