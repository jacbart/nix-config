#!/usr/bin/env bash
# Map the uConsole game buttons (Y/X/B/A, d-pad, select/start) to desktop
# macros via evsieve.
#
# REQUIRES the keyboard's back switch in JOYSTICK mode (PD2 LOW): the buttons
# then report as a HID joystick on a separate evdev device instead of the
# keyboard letters j/k/u/i, so these macros don't collide with typing. The
# L/R shoulder buttons are always mouse buttons in both modes, and the
# trackball click is middle-click.
#
# HID joystick button -> Linux evdev code (hid-input maps button N to
# BTN_JOYSTICK + N-1):
#   X = BTN_TRIGGER, A = BTN_THUMB, B = BTN_THUMB2, Y = BTN_TOP,
#   Select = BTN_BASE3, Start = BTN_BASE4
#
# The hooks below are non-exclusive (no grab), so the buttons keep working as
# a real gamepad for moonlight-embedded / retroarch at the same time.
# To see exactly what each button emits, run:
#   evsieve --input <joystick-device> --print
set -euo pipefail

find_device() {
  local dev name lower
  for dev in /dev/input/event*; do
    [ -e "$dev" ] || continue
    name="$(cat "/sys/class/input/$(basename "$dev")/device/name" 2>/dev/null || true)"
    lower="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
    case "$lower" in
      *uconsole*joystick*) printf '%s' "$dev"; return 0 ;;
    esac
  done
  return 1
}

# Wait for the joystick to enumerate (the switch may be flipped after boot,
# or the device can disappear/reappear across reboots).
while true; do
  dev="$(find_device || true)"
  if [ -n "$dev" ]; then
    evsieve \
      --input "$dev" \
      --hook key:BTN_TRIGGER exec-shell="fuzzel" \
      --hook key:BTN_THUMB exec-shell="foot" \
      --hook key:BTN_THUMB2 exec-shell="vivaldi" \
      --hook key:BTN_TOP exec-shell="niri msg action toggle-overview" \
      || true
  fi
  sleep 2
done
