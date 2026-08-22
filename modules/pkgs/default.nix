# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) { },
  inputs,
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
  tmux-agent-indicator = pkgs.callPackage ./tmux-agent-indicator { };

  # Rebuild fern from the locked flake source with a corrected vendorHash
  # (upstream's FOD hash drifted — see ./fern/default.nix for details).
  fern = pkgs.callPackage ./fern {
    fernSource = inputs.fern.outPath;
    fernVersion = inputs.fern.sourceInfo.shortRev or "dev";
  };
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  uconsole-nx = pkgs.callPackage ./nxengine { };
  calibre-web-automated = pkgs.callPackage ./calibre-web-automated { };
}
