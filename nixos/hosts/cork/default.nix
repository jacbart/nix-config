{ nixos-wsl
, stateVersion
, ...
}: {
  imports = [
    (nixos-wsl.nixosModules.default {
      system.stateVersion = stateVersion;
      wsl.enable = true;
      wsl.defaultUser = "meep";
    })
  ];

  nixpkgs.config.allowBroken = true;
}
