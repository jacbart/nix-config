{ config, ... }:
{
  homeHosts."jackbartlett@sycamore" = {
    system = "aarch64-darwin";
    modules = [
      ../../home/core.nix
      ../../home/shell/default.nix
      ../../home/shell/tools/default.nix
      ../../home/users/jackbartlett/default.nix
    ];
  };
}
