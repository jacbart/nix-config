{
  config,
  inputs,
  ...
}:
{
  nixosHosts.iso-maple = {
    system = "aarch64-linux";
    username = "nixos";
    modules = [
      config.flake.modules.nixos.core
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ../../nixos/hardware/rockpro64.nix
      ../iso/keys.nix
      (
        { pkgs, ... }:
        {
          boot.supportedFilesystems = [ "zfs" ];
          boot.zfs.forceImportRoot = false;

          environment.systemPackages = [
            pkgs.zfs
            pkgs.scripts.install-system
          ];

          # Auto-login on console for convenience
          services.kmscon.autologinUser = "nixos";
        }
      )
    ];
  };
}
