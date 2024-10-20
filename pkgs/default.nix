# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  uconsole-nx = pkgs.callPackage ./nxengine { };
  zed-editor = pkgs.callPackage ./zed-editor { };
  mazter = pkgs.callPackage ./mazter { };
  pmg = pkgs.callPackage ./portmaster-games { };
  ludo = pkgs.callPackage ./ludo { };
}
