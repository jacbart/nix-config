{ pkgs ? (import ../nixpkgs.nix) { } }: {
  br = pkgs.callPackage ./br { };
  brightness = pkgs.callPackage ./brightness { };
  journal = pkgs.callPackage ./journal { };
  upload-to-cache = pkgs.callPackage ./upload-to-cache { };
  volume = pkgs.callPackage ./volume { };
  install-system = pkgs.callPackage ./install-system { };
}
