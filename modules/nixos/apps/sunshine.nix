# Sunshine: game-streaming host (Moonlight clients, e.g. ash the uConsole).
{ ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    # KMS capture (works compositor-independently, needed under niri/nvidia).
    capSysAdmin = true;
    openFirewall = true;
  };
}
