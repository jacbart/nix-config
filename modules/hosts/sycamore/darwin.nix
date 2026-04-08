{ config, ... }:
{
  darwinHosts.sycamore = {
    username = "jackbartlett";
    modules = [ config.flake.modules.darwin.laptop ];
  };
}
