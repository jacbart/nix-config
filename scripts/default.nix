{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  add-zim = pkgs.callPackage ./add-zim { };
  alfred = pkgs.callPackage ./alfred { };
  br = pkgs.callPackage ./br { };
  ide = pkgs.callPackage ./ide { };
  brightness = pkgs.callPackage ./brightness { };
  journal = pkgs.callPackage ./journal { };
  upload-to-cache = pkgs.callPackage ./upload-to-cache { };
  volume = pkgs.callPackage ./volume { };
  install-system = pkgs.callPackage ./install-system { };
}
