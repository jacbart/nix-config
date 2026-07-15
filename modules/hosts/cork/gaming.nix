{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nix-citizen.nixosModules.default ];

  programs.rsi-launcher = {
    enable = true;
    gamescope.enable = true;
  };

  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };

  users.users.meep.extraGroups = [ "gamemode" ];
}
