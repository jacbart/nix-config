{
  description = "NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

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
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/workspace/personal/nix-config
      # nix build .#homeConfigurations."meep@boojum".activationPackage
      homeConfigurations = {
        # Workstations
        "meep@boojum" = libx.mkHome {
          hostname = "boojum";
          username = "meep";
          desktop = "cosmic";
        };
        "jackbartlett@jackjrny" = libx.mkHome {
          hostname = "jackjrny";
          username = "jackbartlett";
          platform = "aarch64-darwin";
        };
        # VMs
        "nixos@cork" = libx.mkHome {
          hostname = "cork";
          username = "nixos";
        };
        # Handhelds
        "meep@ash" = libx.mkHome {
          hostname = "ash";
          username = "meep";
          desktop = "phosh";
          platform = "aarch64-linux";
        };
        # Servers
        "ratatoskr@maple" = libx.mkHome {
          hostname = "maple";
          username = "ratatoskr";
          platform = "aarch64-linux";
        };
        "jack@unicron" = libx.mkHome {
          hostname = "unicron";
          username = "jack";
        };
        "ratatoskr@oak" = libx.mkHome {
          hostname = "oak";
          username = "ratatoskr";
        };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
        #  - nix build .#nixosConfigurations.boojum.config.system.build.toplevel
        boojum = libx.mkHost {
          hostname = "boojum";
          username = "meep";
          desktop = "cosmic";
        };
        # VMs
        # cork = libx.mkHost {
        #   hostname = "cork";
        #   username = "nixos";
        # };
        # Handhelds
        ash = libx.mkHost {
          hostname = "ash";
          username = "meep";
          desktop = "phosh";
          platform = "aarch64-linux";
        };
        # Servers
        maple = libx.mkHost {
          hostname = "maple";
          username = "ratatoskr";
          platform = "aarch64-linux";
        };
        oak = libx.mkHost {
          hostname = "oak";
          username = "ratatoskr";
        };
      };

      # Devshell for bootstrapping; acessible via 'nix develop'
      devShells = libx.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix { inherit pkgs; }
      );

      # nix fmt
      formatter = libx.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );
    };
}
