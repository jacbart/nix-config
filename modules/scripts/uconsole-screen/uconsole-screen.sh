#!/usr/bin/env bash
# Toggle the uConsole panel off/on (bound to the power button).
#
# The CWU50 panel's DPMS off/on path is flaky (see uconsole-display.nix), so
# "screen off" drives the OCP8178 backlight to 0 instead of a DPMS blank.
# max_brightness is 9; the prior level is stashed in the session runtime dir
# and restored on the next press.
set -euo pipefail

state="$XDG_RUNTIME_DIR/uconsole-screen-brightness"
cur="$(brightnessctl get 2>/dev/null || echo 0)"

if [ "$cur" != "0" ]; then
  printf '%s' "$cur" > "$state"
  brightnessctl set 0
else
  if [ -f "$state" ] && [ -s "$state" ]; then
    brightnessctl set "$(cat "$state")"
  else
    brightnessctl set 5
  fi
  rm -f "$state"
fi
