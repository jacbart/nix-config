# One import per host module that populates nixosHosts, darwinHosts, or homeHosts.
# See `modules/configurations.nix` for how these become flake outputs.
{ ... }:
{
  imports = [
    ./sycamore/darwin.nix
    ./jackjrny/darwin.nix
    ./ash/nixos.nix
    ./boojum/nixos.nix
    ./cork/nixos.nix
    ./iso/nixos.nix
    ./maple/nixos.nix
    ./mesquite/nixos.nix
    ./oak/nixos.nix
    ./unicron/home.nix
    ./sycamore/home.nix
    ./jackjrny/home.nix
    ./oak/home.nix
    ./mesquite/home.nix
    ./maple/home.nix
    ./cork/home.nix
    ./boojum/home.nix
    ./ash/home.nix
  ];
}
