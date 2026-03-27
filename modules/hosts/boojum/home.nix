{ config, ... }:
{
  homeHosts."meep@boojum" = {
    system = "x86_64-linux";
    modules = [
      ../../home/core.nix
      ../../home/shell/default.nix
      ../../home/shell/tools/default.nix
      ../../home/users/meep/default.nix
      ../../home/desktop/default.nix
    ]
    ++ [
      ../../home/users/meep/hosts/boojum.nix
    ];
  };
}
