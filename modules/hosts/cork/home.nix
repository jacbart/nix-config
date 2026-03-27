{ config, ... }:
{
  homeHosts."meep@cork" = {
    system = "x86_64-linux";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/meep/default.nix
      ../../home/desktop/default.nix
    ];
  };
}
