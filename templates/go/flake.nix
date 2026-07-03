{
  description = "Go project dev environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Go toolchain
            go
            gopls
            gofumpt
            delve
            golangci-lint
            # Editor baseline: flake.nix, docs, config files
            nil # nix LSP
            nixfmt # nix formatter
            markdown-oxide # markdown LSP
            prettier # markdown/json/yaml formatter
            yaml-language-server # .golangci.yml, CI, goreleaser
          ];
        };
      });
    };
}
