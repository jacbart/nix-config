{ lib, ... }:
{
  imports = [
    ../_mixins/services/bluetooth.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/services/openssh.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
