{
  description = "headplane flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs
    , nix-formatter-pack
    , ...
    }:
    let
      # inherit (nixpkgs) lib;
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs allSystems (system:
          f {
            pkgs = import nixpkgs { inherit system; };
          });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.callPackage ./default.nix { inherit pkgs; };
      });
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.callPackage ./shell.nix { inherit pkgs; };
      });
      # nix fmt
      formatter = nixpkgs.lib.genAttrs allSystems (
        system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = true;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );
      # hydraJobs."PROJECT_NAME" = forAllSystems ({ pkgs }: self.packages.${pkgs.stenv.system}.default);
    };
}
