# Headless virtual display for cork (NVIDIA 3060 Ti, niri + Sunshine).
#
# With no monitor attached the GPU exposes no output, so niri has nothing to
# composite and Sunshine's KMS capture has nothing to stream. The proprietary
# NVIDIA driver won't enumerate modes from a force-enabled connector unless
# (a) the connector is forced "connected" via `video=<connector>:e` and
# (b) a custom EDID carrying the HDMI VSDB + HDMI Forum VSDB blocks is loaded
# from the initramfs (the VSDBs are what unlock >1080p60 bandwidth on the
# virtual connector). See:
#   https://gist.github.com/HarryAnkers/8dbf551d66f00e8156ef4dd2b2b090a0
#
# Pick a connector that is physically unused, then verify after reboot (on
# cork) that it shows `connected` and lists modes:
#   for p in /sys/class/drm/card*-*/status; do
#     echo "$(basename "$(dirname "$p")"): $(cat "$p")"
#   done
#   cat /sys/class/drm/card*-${connector}/modes
#
# NOTE: the kernel's DPMS must never turn this virtual output off — the NVIDIA
# driver drops the CRTC and it cannot be woken without a reboot. noctalia's
# idle screen-off is disabled on cork for this reason (niri-desktop.headless).
{
  pkgs,
  ...
}:
let
  connector = "DP-2";

  edidFirmware = pkgs.runCommand "nvidia-virtual-display-edid" { } ''
    mkdir -p $out/lib/firmware/edid
    ${pkgs.python3}/bin/python3 ${./mk-virtual-edid.py} $out/lib/firmware/edid/virtual-display.bin
  '';
in
{
  hardware.firmware = [ edidFirmware ];

  boot.initrd.systemd.contents."/lib/firmware/edid/virtual-display.bin" = {
    source = "${edidFirmware}/lib/firmware/edid/virtual-display.bin";
  };

  boot.kernelParams = [
    "drm.edid_firmware=${connector}:edid/virtual-display.bin"
    "video=${connector}:e"
  ];
}
