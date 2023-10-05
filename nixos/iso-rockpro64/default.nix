{ lib, ... }:
{
  imports = [
    ../_mixins/hardware/rockpro64.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;
}
