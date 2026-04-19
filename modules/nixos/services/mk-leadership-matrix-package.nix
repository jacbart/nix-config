# Curried helper: (import ./mk-leadership-matrix-package.nix { inherit pkgs inputs; }) [ "systemd" "zfs" "smart" ];
{ pkgs, inputs }:
nativeComponents: import ./leadership-matrix-package.nix { inherit pkgs inputs nativeComponents; }
