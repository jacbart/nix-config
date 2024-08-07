{
  description = "NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , vscode-server
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/workspace/personal/nix-config
      # nix build .#homeConfigurations."meep@boojum".activationPackage
      homeConfigurations = {
        # .iso images
        "nixos@iso-console" = libx.mkHome { hostname = "iso-console"; username = "nixos"; };
        "nixos@iso-desktop" = libx.mkHome { hostname = "iso-desktop"; username = "nixos"; desktop = "hyprland"; };
        "nixos@iso-rockpro64" = libx.mkHome { hostname = "iso-rockpro64"; username = "nixos"; };
        "nixos@iso-uconsole" = libx.mkHome { hostname = "iso-uconsole"; username = "nixos"; };
        # Workstations
        "meep@boojum" = libx.mkHome { hostname = "boojum"; username = "meep"; desktop = "hyprland"; };
        "meep@ash" = libx.mkHome { hostname = "ash"; username = "meep"; desktop = "hyprland"; platform = "aarch64-linux"; };
        "jackbartlett@jackjrny" = libx.mkHome { hostname = "jackjrny"; username = "jackbartlett"; platform = "aarch64-darwin"; };
        # Servers
        "meep@maple" = libx.mkHome { hostname = "maple"; username = "meep"; platform = "aarch64-linux"; };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-console = libx.mkHost { hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; };
        iso-rockpro64 = libx.mkHost { hostname = "iso-rockpro64"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix"; };
        iso-uconsole = libx.mkHost { hostname = "iso-uconsole"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix"; };
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
        #  - nix build .#nixosConfigurations.boojum.config.system.build.toplevel
        boojum = libx.mkHost { hostname = "boojum"; username = "meep"; desktop = "hyprland"; };
        ash = libx.mkHost { hostname = "ash"; username = "meep"; desktop = "hyprland"; };
        # Servers
        maple = libx.mkHost { hostname = "maple"; username = "ratatoskr"; };
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
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
