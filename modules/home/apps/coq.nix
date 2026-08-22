# Caves of Qud launcher on aarch64 (uConsole).
#
# The wrapper is self-contained: `writeShellApplication` bakes both
# library sets in at derivation time — cross x86_64 glibc/libgcc (via
# the `pkgs.x86` overlay in modules/flake/overlays.nix) for the emulated
# side, and native aarch64 X11/wayland/GL/audio libs for box64's wrapped
# dlopens. No NixOS-side file, no box64 --lib-path, no nixos-rebuild
# needed. See ../scripts/coq/ for the wrapper.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.scripts.coq
  ];
}
