{
  description = "jacbart's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # patched caddy with cloudflare provider
    caddy-with-modules.url = "github:jacbart/nixos-caddy-patched";

    jaws.url = "github:jacbart/jaws";
    ff.url = "github:jacbart/ff";

    leadership-matrix.url = "git+ssh://git@github.com/taybart/leadership-matrix.git?ref=feat/configurable";
    rest.url = "github:taybart/rest";

    nix-diff.url = "github:Mic92/nix-diff-rs";
    lan-mouse.url = "github:feschber/lan-mouse";

    hydra.url = "github:NixOS/hydra";
    hydra.inputs.nixpkgs.follows = "nixpkgs";

    nixupd.url = "git+ssh://git@github.com/jacbart/nixupd.git?ref=main";
    nixupd.inputs.nixpkgs.follows = "nixpkgs";

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-uconsole.url = "github:jacbart/nixos-uconsole";
    nixos-uconsole.inputs.nixpkgs.follows = "nixpkgs";
    nixos-uconsole.inputs.nixos-hardware.follows = "nixos-hardware";

    #### Personal repos ####
    secrets = {
      url = "git+ssh://git@github.com/jacbart/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/flake/flake-parts.nix
        ./modules/flake/overlays.nix
        ./modules/flake/packages.nix
        ./modules/flake/devshell.nix
        ./modules/flake/formatter.nix
        ./modules/flake/systems.nix
        ./modules/vars.nix
        ./modules/configurations.nix
        ./modules/pkgs.nix
        ./modules/scripts.nix

        # Core modules that export to flake.modules
        ./modules/nixos/core.nix
        ./modules/home/core.nix
        ./modules/darwin/core.nix

        # Host configurations
        ./modules/hosts/sycamore/darwin.nix
        ./modules/hosts/jackjrny/darwin.nix
        ./modules/hosts/ash/nixos.nix
        ./modules/hosts/boojum/nixos.nix
        ./modules/hosts/cork/nixos.nix
        ./modules/hosts/iso/nixos.nix
        ./modules/hosts/maple/nixos.nix
        ./modules/hosts/mesquite/nixos.nix
        ./modules/hosts/oak/nixos.nix
        ./modules/hosts/unicron/home.nix
        ./modules/hosts/sycamore/home.nix
        ./modules/hosts/jackjrny/home.nix
        ./modules/hosts/oak/home.nix
        ./modules/hosts/mesquite/home.nix
        ./modules/hosts/maple/home.nix
        ./modules/hosts/cork/home.nix
        ./modules/hosts/boojum/home.nix
        ./modules/hosts/ash/home.nix
      ];
    };
}
