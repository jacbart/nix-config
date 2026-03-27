{ config, ... }:
{
  homeHosts."meep@ash" = {
    system = "aarch64-linux";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/meep/default.nix
      ../../home/desktop/default.nix
    ];
  };
}
