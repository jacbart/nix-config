{
  description = "Web (JS/HTML/CSS) project dev environment";

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
            nodejs_24 # bundles corepack for pnpm/yarn
            typescript
            typescript-language-server
            vscode-langservers-extracted # html/css/json + eslint servers
            prettier
          ];
        };
      });
    };
}
