#!/usr/bin/env bash
# Stream from cork (Sunshine host) to ash (uConsole CM4) over Tailscale.
# Uses moonlight-embedded (software decode via FFmpeg, works on CM4).
#
# Usage:
#   moonlight-ash              # stream Desktop (720p 30fps H264)
#   moonlight-ash list         # list available apps on cork
#   moonlight-ash stream <app> # stream a specific app

set -euo pipefail

CORK_HOST="cork"
RESOLUTION="720"
FPS="30"
CODEC="h264"
DEFAULT_APP="Desktop"

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

case "${1:-}" in
  list)
    echo "Available apps on cork ($CORK_IP):"
    moonlight list "$CORK_IP"
    ;;
  stream)
    APP="${2:-$DEFAULT_APP}"
    echo "Streaming '$APP' from cork ($CORK_IP) at ${RESOLUTION}p/${FPS}fps ($CODEC)..."
    moonlight stream \
      -"$RESOLUTION" \
      -fps "$FPS" \
      -codec "$CODEC" \
      -app "$APP" \
      "$CORK_IP"
    ;;
  "")
    echo "Streaming Desktop from cork ($CORK_IP) at ${RESOLUTION}p/${FPS}fps ($CODEC)..."
    moonlight stream \
      -"$RESOLUTION" \
      -fps "$FPS" \
      -codec "$CODEC" \
      -app "$DEFAULT_APP" \
      "$CORK_IP"
    ;;
  *)
    echo "Unknown action: $1" >&2
    echo "Usage: moonlight-ash [stream|list] [app-name]" >&2
    exit 1
    ;;
esac
