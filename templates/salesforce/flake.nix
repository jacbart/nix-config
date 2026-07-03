{
  description = "Salesforce project dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # The salesforce devShell lives in jacbart's nix-config. Taking it as an input
    # locks all of that flake's transitive inputs (incl. private git+ssh ones);
    # output eval is lazy, so only the `salesforce` shell actually builds.
    sf.url = "github:jacbart/nix-config";
    sf.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      sf,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAll = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAll (system: {
        default = sf.devShells.${system}.salesforce;
      });
    };
}
