{ config, ... }:
{
  homeHosts."jack@unicron" = {
    system = "x86_64-linux";
    modules = [
      ../../home/core.nix
      ../../home/shell/default.nix
      ../../home/shell/tools/default.nix
      ../../home/users/jack/default.nix
    ]
    ++ [
      ../../home/users/jack/hosts/unicron.nix
    ];
  };
}
