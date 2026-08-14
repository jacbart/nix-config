#!/usr/bin/env bash
# Stream from cork (Sunshine host) to ash (uConsole CM4) over Tailscale.
# Uses moonlight-embedded with software decoding (no HW decoder on CM4/NixOS).
#
# Usage:
#   moonlight-ash              # default: 720p 30fps H264
#   moonlight-ash desktop      # stream the desktop app
#   moonlight-ash <app-name>   # stream a specific Sunshine app

set -euo pipefail

CORK_HOST="cork"
RESOLUTION="720"
FPS="30"
CODEC="h264"

# Resolve cork's Tailscale IPv4 at runtime.
resolve_tailscale_ip() {
  local host="$1"
  local ip
  ip=$(tailscale status 2>/dev/null \
    | awk -v h="$host" '$2 == h { print $1; exit }')
  if [[ -z "$ip" ]]; then
    echo "ERROR: could not resolve Tailscale IP for '$host'. Is tailscaled running?" >&2
    echo "Hint: run 'tailscale status' to check." >&2
    exit 1
  fi
  echo "$ip"
}

CORK_IP=$(resolve_tailscale_ip "$CORK_HOST")

echo "Streaming from cork ($CORK_IP) at ${RESOLUTION}p/${FPS}fps ($CODEC)..."

if [[ -n "${1:-}" ]]; then
  moonlight stream \
    -"$RESOLUTION" \
    -fps "$FPS" \
    -codec "$CODEC" \
    -app "$1" \
    "$CORK_IP"
else
  moonlight stream \
    -"$RESOLUTION" \
    -fps "$FPS" \
    -codec "$CODEC" \
    "$CORK_IP"
fi
