# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  fex-cli = pkgs.callPackage ./fex { };
  uconsole-nx = pkgs.callPackage ./nxengine { };
  mazter = pkgs.callPackage ./mazter { };
  koreader-sync-server = pkgs.callPackage ./koreader-sync-server { };
  fern = pkgs.callPackage ./fern { };
  pgsync = pkgs.callPackage ./pgsync { };
  calibre-web-automated = pkgs.callPackage ./calibre-web-automated { };
  apex-jorje-lsp = pkgs.callPackage ./apex-jorje-lsp { };
  tree-sitter-sfapex = pkgs.callPackage ./tree-sitter-sfapex { };
  lwc-language-server = pkgs.callPackage ./lwc-language-server { };
  sf-cli = pkgs.callPackage ./sf-cli { };
  prettier-apex = pkgs.callPackage ./prettier-apex { };
}
