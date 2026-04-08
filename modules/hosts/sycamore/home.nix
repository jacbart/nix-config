{ config, ... }:
{
  homeHosts."jackbartlett@sycamore" = {
    system = "aarch64-darwin";
    shellProfile = "dev-heavy";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/jackbartlett/default.nix
    ];
  };
}
