{ config, ... }:
{
  homeHosts."jack@unicron" = {
    system = "x86_64-linux";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/jack/default.nix
    ]
    ++ [
      ../../home/users/jack/hosts/unicron.nix
    ];
  };
}
