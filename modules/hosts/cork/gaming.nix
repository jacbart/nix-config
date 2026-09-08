{ config, lib, ... }:
{
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;

  # ntsync: modern Wine sync primitive (general Proton/Wine perf). /dev/ntsync
  # is 0666 by default, so no udev rule is needed.
  boot.kernelModules = [ "ntsync" ];

  # High fd limit for Wine/Proton titles (was rsi-launcher's setLimits).
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "16777216";
    }
  ];

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
