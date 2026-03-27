{
  inputs,
  outputs,
  stateVersion,
  vars,
  ...
}:
{
  # Helper function for generating home-manager configs
  mkHome =
    {
      hostname,
      username,
      desktop ? null,
      platform ? "x86_64-linux",
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          vars
          ;
      };
      modules = [
        ../home-manager
      ];
    };

  # Helper function for generating darwin host configs
  mkDarwinHost =
    {
      hostname,
      username,
      desktop ? null,
    }:
    let
      darwinModule =
        { ... }:
        {
          imports = [
            ../darwin/default.nix
          ];
        };
    in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          username
          stateVersion
          vars
          ;
      };
      modules = [
        darwinModule
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };

  # Helper function for generating host configs
  mkHost =
    {
      hostname,
      username,
      desktop ? null,
      installer ? null,
      platform ? "x86_64-linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          username
          platform
          stateVersion
          vars
          ;
      };
      modules = [
        ../nixos
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (inputs.nixpkgs.lib.optionals (platform == "x86_64-linux") [
        { programs.nix-ld.enable = true; }
      ])
      ++ (inputs.nixpkgs.lib.optionals (installer != null) [
        installer
      ])
      ++ (inputs.nixpkgs.lib.optionals (builtins.elem hostname [ "ash" ]) [
        inputs.nixos-uconsole.nixosModules.default
        inputs.nixos-uconsole.nixosModules."kernel-6.1-potatomania"
      ]);
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
