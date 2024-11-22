{ pkgs
, lib
, ...
}:
let
  isX86_64 = pkgs.system == "x86_64-linux";
in
{
  programs.nix-ld.dev.libraries =
    lib.optional isX86_64 pkgs.stdenv.cc.cc.lib;
}
