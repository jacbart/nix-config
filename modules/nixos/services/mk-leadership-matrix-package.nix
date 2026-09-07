# Curried helper retained so host configs keep their existing call shape
# (`lm [ "systemd" "zfs" "smart" ]`); the argument is now ignored since the
# `simple` branch ships a single package with no native-components split.
{ pkgs, inputs }:
_nativeComponents: import ./leadership-matrix-package.nix { inherit pkgs inputs; }
