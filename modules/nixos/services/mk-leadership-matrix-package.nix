# Curried helper: (import ./mk-leadership-matrix-package.nix { inherit pkgs inputs; }) [ "systemd" ];
{ pkgs, inputs }:
cargoFeatures:
import ./leadership-matrix-package.nix { inherit pkgs inputs cargoFeatures; }
