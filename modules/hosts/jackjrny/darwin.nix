{ config, ... }:
{
  darwinHosts.jackjrny = {
    username = "jackbartlett";
    modules = [
      config.flake.modules.darwin.core
      {
        users.users.jackbartlett = {
          home = "/Users/jackbartlett";
          shell = "/run/current-system/sw/bin/zsh";
        };
      }
    ];
  };
}
