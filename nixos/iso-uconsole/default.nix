{ lib, ... }:
{
  imports = [
    ../_mixins/hardware/uconsole.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowBroken = true;
}
