{ config, ... }:
{
  homeHosts."meep@ash" = {
    system = "aarch64-linux";
    modules = [
      ../../home/core.nix
      ../../home/shell/default.nix
      ../../home/shell/tools/default.nix
      ../../home/users/meep/default.nix
      ../../home/desktop/default.nix
    ];
  };
}
