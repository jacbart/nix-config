{ config, ... }:
{
  darwinHosts.jackjrny = {
    username = "jackbartlett";
    modules = [ config.flake.modules.darwin.laptop ];
  };
}
