# Sunshine: game-streaming host (Moonlight clients, e.g. ash the uConsole).
{ pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    # KMS capture (works compositor-independently, needed under niri/nvidia).
    capSysAdmin = true;
    openFirewall = true;
    # Wrap sunshine with CUDA libraries so NVENC encoder works.
    package = pkgs.sunshine.override { cudaSupport = true; };

    # Emulate a Nintendo Switch Pro controller so Steam shows Nintendo-style
    # button prompts (matches the uConsole's physical button layout).
    settings = {
      gamepad = "switch";
    };
  };

  # Enable VA-API video acceleration for NVIDIA (nvidia-vaapi-driver).
  hardware.nvidia.videoAcceleration = true;
}
