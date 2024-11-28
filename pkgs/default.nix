# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { } }: {
  headplane = pkgs.callPackage ./headplane { };
  uconsole-nx = pkgs.callPackage ./nxengine { };
  mazter = pkgs.callPackage ./mazter { };
  pmg = pkgs.callPackage ./portmaster-games { };
  ludo = pkgs.callPackage ./ludo { };
}
