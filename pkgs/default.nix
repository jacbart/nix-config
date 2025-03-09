# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { } }: {
  ebou = pkgs.callPackage ./ebou { };
  headplane = pkgs.callPackage ./headplane { };
  uconsole-nx = pkgs.callPackage ./nxengine { };
  mazter = pkgs.callPackage ./mazter { };
  pmg = pkgs.callPackage ./portmaster-games { };
  libro = pkgs.callPackage ./libro-client { };
  ludo = pkgs.callPackage ./ludo { };
}
