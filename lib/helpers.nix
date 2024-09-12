{ inputs, outputs, stateVersion, ... }: {
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? "x86_64-linux" }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${platform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion;
    };
    modules = [ 
      ../home-manager
    ];
  };

  # Helper function for generating host configs
  mkHost = { hostname, username, desktop ? null, installer ? null }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs desktop hostname username stateVersion;
    };
    modules = [
      ../nixos
      inputs.sops-nix.nixosModules.sops
      inputs.lix-module.nixosModules.default
    ] ++ (inputs.nixpkgs.lib.optionals (installer != null) [
      installer
    ]) ++ (inputs.nixpkgs.lib.optionals (desktop == "cosmic") [
      {
        nix.settings = {
          substituters = [ "https://cosmic.cachix.org/" ];
          trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
        };
      }
      inputs.nixos-cosmic.nixosModules.default
    ]) ++ (inputs.nixpkgs.lib.optionals (builtins.elem hostname [ "ash" ] ) [
      inputs.nixos-uconsole.nixosModules.default
      inputs.nixos-uconsole.nixosModules."kernel-6.1-potatomania"
    ]);
  };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
