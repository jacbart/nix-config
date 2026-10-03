# meep@cork only: headless tower, controlled over VNC (wayvnc) or Moonlight
# (Sunshine). Disable noctalia's idle lock + screen-off so the remote session
# is never locked or DPMS-blanked (the virtual display CRTC cannot be woken
# without a reboot).
{ ... }:
{
  niri-desktop.headless = true;
}
