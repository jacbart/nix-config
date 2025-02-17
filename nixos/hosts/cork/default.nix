{ nixos-wsl
, ...
}: {
  imports = [
    nixos-wsl.nixosModules.default
    {
      system.stateVersion = "24.11";
      wsl.enable = true;
      wsl.defaultUser = "meep";
    }
  ];

  nixpkgs.config.allowBroken = true;
}
