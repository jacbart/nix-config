{ nixpkgs, nixos-uconsole, ... }: {
  nixosConfigurations.uconsole = nixpkgs.lib.nixosSystem {
      modules = [ 
        nixos-uconsole.nixosModules.default
        nixos-uconsole.nixosModules."kernel-6.1-potatomania"
      ];
    };
}
