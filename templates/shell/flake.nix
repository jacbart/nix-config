{
  description = "Shell (bash/zsh) project dev environment";

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
            # Shell toolchain
            bashInteractive
            zsh
            shfmt
            shellcheck
            bash-language-server
            systemd-language-server # .service/.timer/.socket units
            # Editor baseline: flake.nix, docs, config files
            nil # nix LSP
            nixfmt # nix formatter
            markdown-oxide # markdown LSP
            prettier # markdown/json/yaml formatter
            yaml-language-server # CI, pre-commit
          ];
        };
      });
    };
}
