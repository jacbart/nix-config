{ config, ... }:
{
  homeHosts."jackbartlett@jackjrny" = {
    system = "aarch64-darwin";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/jackbartlett/default.nix
    ];
  };
}
