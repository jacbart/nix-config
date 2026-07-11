{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  add-zim = pkgs.callPackage ./add-zim { };
  br = pkgs.callPackage ./br { };
  unicroninit = pkgs.callPackage ./unicroninit { };
  brightness = pkgs.callPackage ./brightness { };
  gitclean = pkgs.callPackage ./gitclean { };
  journal = pkgs.callPackage ./journal { };
  upload-to-cache = pkgs.callPackage ./upload-to-cache { };
  volume = pkgs.callPackage ./volume { };
  install-system = pkgs.callPackage ./install-system { };
  summarize-commit = pkgs.callPackage ./summarize-commit { };
  hx-go-tags = pkgs.callPackage ./hx-go-tags { };
  apex-impls = pkgs.callPackage ./apex-impls { };
  resolve = pkgs.callPackage ./resolve { };
}
