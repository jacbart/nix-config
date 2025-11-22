{
  description = "jacbart's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-ld.url = "github:Mic92/nix-ld";
    # nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # patched caddy with cloudflare provider
    caddy-with-modules.url = "github:jacbart/nixos-caddy-patched";

    jaws.url = "github:jacbart/jaws";
    ff.url = "github:jacbart/ff";
    trees.url = "github:jacbart/trees";
    rest.url = "github:taybart/rest";

    helix.url = "github:jacbart/helix/steel-event-system";
    nix-diff.url = "github:Mic92/nix-diff-rs";
    lan-mouse.url = "github:feschber/lan-mouse";

    hydra.url = "github:NixOS/hydra";
    hydra.inputs.nixpkgs.follows = "nixpkgs";

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
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = lib.mkDefault "25.05";
      utils = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/workspace/personal/nix-config
      # nix build .#homeConfigurations."meep@boojum".activationPackage
      homeConfigurations = {
        # Workstations
        "meep@boojum" = utils.mkHome {
          hostname = "boojum";
          username = "meep";
          desktop = "cosmic";
        };
        "jackbartlett@jackjrny" = utils.mkHome {
          hostname = "jackjrny";
          username = "jackbartlett";
          platform = "aarch64-darwin";
        };
        "meep@cork" = utils.mkHome {
          hostname = "cork";
          username = "meep";
          desktop = "cosmic";
        };
        # Handhelds
        "meep@ash" = utils.mkHome {
          hostname = "ash";
          username = "meep";
          desktop = "phosh";
          platform = "aarch64-linux";
        };
        # Servers
        "ratatoskr@maple" = utils.mkHome {
          hostname = "maple";
          username = "ratatoskr";
          platform = "aarch64-linux";
        };
        "jack@unicron" = utils.mkHome {
          hostname = "unicron";
          username = "jack";
        };
        "ratatoskr@oak" = utils.mkHome {
          hostname = "oak";
          username = "ratatoskr";
        };
      };
      nixosConfigurations = {
        # .iso images
        # sh: nix build .#nixosConfigurations.iso.config.system.build.isoImage
        iso = utils.mkHost {
          hostname = "iso";
          username = "nixos";
          installer = inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
        };

        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
        #  - nix build .#nixosConfigurations.boojum.config.system.build.toplevel
        boojum = utils.mkHost {
          hostname = "boojum";
          username = "meep";
          desktop = "cosmic";
        };
        cork = utils.mkHost {
          hostname = "cork";
          username = "meep";
          desktop = "cosmic";
        };
        # Handhelds
        ash = utils.mkHost {
          hostname = "ash";
          username = "meep";
          desktop = "phosh";
          platform = "aarch64-linux";
        };
        # Servers
        maple = utils.mkHost {
          hostname = "maple";
          username = "ratatoskr";
          platform = "aarch64-linux";
        };
        oak = utils.mkHost {
          hostname = "oak";
          username = "ratatoskr";
        };
      };

      # Devshell for bootstrapping; acessible via 'nix develop'
      devShells = utils.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix { inherit pkgs; }
      );

      # nix fmt
      formatter = utils.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = utils.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );
    };
}
