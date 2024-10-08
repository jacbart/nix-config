{
  description = "NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hydra.url = "github:NixOS/hydra";
    hydra.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-uconsole.url = "git+https://git.vdx.hu/voidcontext/nixos-uconsole?ref=improve-ergonomy";
    nixos-uconsole.inputs.nixpkgs.follows = "nixpkgs";
    nixos-uconsole.inputs.nixos-hardware.follows = "nixos-hardware";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    # lan-mouse.url = "github:feschber/lan-mouse";
    # lan-mouse.inputs.nixpkgs.follows = "nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs-unstable";

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    #### Personal repos ####
    mySecrets = {
      url = "git+ssh://git@github.com/jacbart/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , hydra
    , vscode-server
    # , lan-mouse
    , nixos-cosmic
    , nixos-hardware
    , nixos-uconsole
    , lix-module
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = lib.mkForce "24.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/workspace/personal/nix-config
      # nix build .#homeConfigurations."meep@boojum".activationPackage
      homeConfigurations = {
        # .iso images
        "nixos@iso-desktop" = libx.mkHome { hostname = "iso-desktop"; username = "nixos"; desktop = "cosmic"; };
        # Workstations
        "meep@boojum" = libx.mkHome { hostname = "boojum"; username = "meep"; desktop = "cosmic"; };
        "meep@ash" = libx.mkHome { hostname = "ash"; username = "meep"; desktop = "xfce"; platform = "aarch64-linux"; };
        "jackbartlett@jackjrny" = libx.mkHome { hostname = "jackjrny"; username = "jackbartlett"; platform = "aarch64-darwin"; };
        # Servers
        "ratatoskr@maple" = libx.mkHome { hostname = "maple"; username = "ratatoskr"; platform = "aarch64-linux"; };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-desktop = libx.mkHost { hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; };
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
        #  - nix build .#nixosConfigurations.boojum.config.system.build.toplevel
        boojum = libx.mkHost { hostname = "boojum"; username = "meep"; desktop = "cosmic"; };
        ash = libx.mkHost { hostname = "ash"; username = "meep"; desktop = "xfce"; platform = "aarch64-linux"; };
        # Servers
        maple = libx.mkHost { hostname = "maple"; username = "ratatoskr"; platform = "aarch64-linux"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop'
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # nix fmt
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = (import ./overlays { inherit inputs; });

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
