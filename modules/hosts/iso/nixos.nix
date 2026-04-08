{
  config,
  inputs,
  ...
}:
{
  nixosHosts.iso = {
    username = "nixos";
    modules = [
      config.flake.modules.nixos.core
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ./keys.nix
    ];
  };
}
