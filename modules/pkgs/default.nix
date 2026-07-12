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
  mazter = pkgs.callPackage ./mazter { };
  pgsync = pkgs.callPackage ./pgsync { };
  apex-jorje-lsp = pkgs.callPackage ./apex-jorje-lsp { };
  tree-sitter-sfapex = pkgs.callPackage ./tree-sitter-sfapex { };
  lwc-language-server = pkgs.callPackage ./lwc-language-server { };
  sf-cli = pkgs.callPackage ./sf-cli { };
  prettier-apex = pkgs.callPackage ./prettier-apex { };
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  uconsole-nx = pkgs.callPackage ./nxengine { };
  koreader-sync-server = pkgs.callPackage ./koreader-sync-server { };
  calibre-web-automated = pkgs.callPackage ./calibre-web-automated { };
}
