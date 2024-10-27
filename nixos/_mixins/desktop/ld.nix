{ pkgs, lib, ... }: let
  inherit (pkgs) system;
in {
  programs.nix-ld.dev.libraries = [
    # pkgs.openal # ludo
    # pkgs.libGL # ludo
    # pkgs.wlroots # ludo wayland
  ] ++ lib.optional (if system == "x86_64-linux" then pkgs.libstdcxx5 else null); # zed
}
