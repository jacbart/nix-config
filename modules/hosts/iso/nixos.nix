{
  config,
  inputs,
  ...
}:
{
  nixosHosts.iso = {
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/services/openssh.nix
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ./keys.nix
    ];
  };
}
