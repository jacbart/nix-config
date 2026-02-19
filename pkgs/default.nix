# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  fex-cli = pkgs.callPackage ./fex { };
  uconsole-nx = pkgs.callPackage ./nxengine { };
  mazter = pkgs.callPackage ./mazter { };
}
