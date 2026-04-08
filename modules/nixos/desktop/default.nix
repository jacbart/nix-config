{
  desktop,
  lib,
  ...
}:
{
  imports = lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

  boot = {
    kernelParams = [ "loglevel=4" ];
    plymouth = {
      enable = true;
      theme = "solar";
    };
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };
}
