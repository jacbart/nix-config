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

  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    # Limit shader cache to prevent VRAM exhaustion during long Proton sessions.
    __GL_MaxShaderCacheSize = "1073741824"; # 1 GB
    # Cap shader compiler threads to reduce CPU/GPU contention.
    __GL_ShaderCompilerThreadCount = "4";
    # Enable vsync to reduce tearing and GPU load spikes.
    __GL_SYNC_TO_VBLANK = "1";
  };

  users.users.meep.extraGroups = [ "gamemode" ];
}
