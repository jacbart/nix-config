# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) { },
}:
let
  inherit (pkgs) lib;
in
{
  fex-cli = pkgs.callPackage ./fex { };
  uconsole-nx = pkgs.callPackage ./nxengine { };
  mazter = pkgs.callPackage ./mazter { };
  koreader-sync-server = pkgs.callPackage ./koreader-sync-server { };
  fern = pkgs.callPackage ./fern { };
}
// lib.optionalAttrs pkgs.stdenv.isDarwin {
  cornerfix = pkgs.callPackage ./cornerfix { };
}
