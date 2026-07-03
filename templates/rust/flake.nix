{
  description = "Rust project dev environment";

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
            # Rust toolchain
            rustc
            cargo
            rust-analyzer
            clippy
            rustfmt
            # Editor baseline: flake.nix, docs, config files (incl. Cargo.toml)
            nil # nix LSP
            nixfmt # nix formatter
            markdown-oxide # markdown LSP
            prettier # markdown/json formatter
            taplo # toml LSP + formatter (Cargo.toml, rustfmt.toml, clippy.toml)
          ];
          # rust-analyzer resolves std sources from here.
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
    };
}
