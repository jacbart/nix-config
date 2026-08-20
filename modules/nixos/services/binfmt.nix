# Cross-architecture build support via kernel binfmt_misc + QEMU user-mode emulation.
# Replaces the former custom qemu.nix module with the standard NixOS option.
#
# `boot.binfmt.emulatedSystems` automatically registers QEMU binfmt handlers
# AND sets `extra-platforms` so Nix routes foreign-arch derivations to this
# machine.  Imported via profileWorkstationMedia on x86_64 hosts (cork, boojum)
# so they can build aarch64-linux derivations — the outputs are real native
# aarch64 store paths that substitute cleanly against the shared cache.
#
# Emulation is slower than native, but unlike cross-compilation (pkgsCross)
# it produces derivations identical to native ones, keeping the cache unified.
{ lib, ... }:
{
  boot.binfmt.emulatedSystems = lib.mkDefault [ "aarch64-linux" ];
}
