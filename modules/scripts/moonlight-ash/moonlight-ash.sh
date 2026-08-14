#!/usr/bin/env bash
# Stream from cork (Sunshine host) to ash (uConsole CM4) over Tailscale.
# Wraps moonlight-qt with software H264 decoding (no HW decoder on CM4/NixOS).
#
# Usage:
#   moonlight-ash              # launch moonlight-qt GUI (pair, browse apps)
#   moonlight-ash stream       # stream Desktop directly (720p 30fps H264)
#   moonlight-ash stream <app> # stream a specific app

set -euo pipefail

CORK_HOST="cork"
RESOLUTION="720"
FPS="30"

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

MOONLIGHT_FLAGS=(
  -appoption streamingpreferences.videoDecoderSelection=2
  -appoption streamingpreferences.videoCodecConfig=1
)

case "${1:-}" in
  stream)
    CORK_IP=$(resolve_tailscale_ip "$CORK_HOST")
    if [[ -n "${2:-}" ]]; then
      echo "Streaming '$2' from cork ($CORK_IP) at ${RESOLUTION}p/${FPS}fps (H264, software decode)..."
      moonlight "${MOONLIGHT_FLAGS[@]}" \
        -appoption "streamingpreferences.width=$RESOLUTION" \
        -appoption "streamingpreferences.height=$((RESOLUTION * 16 / 9))" \
        -appoption "streamingpreferences.fps=$FPS" \
        -start "$2" "$CORK_IP"
    else
      echo "Streaming Desktop from cork ($CORK_IP) at ${RESOLUTION}p/${FPS}fps (H264, software decode)..."
      moonlight "${MOONLIGHT_FLAGS[@]}" \
        -appoption "streamingpreferences.width=$RESOLUTION" \
        -appoption "streamingpreferences.height=$((RESOLUTION * 16 / 9))" \
        -appoption "streamingpreferences.fps=$FPS" \
        "$CORK_IP"
    fi
    ;;
  *)
    echo "Launching moonlight-qt (software H264 decode)..."
    echo "  Pair with cork first, then select an app to stream."
    echo ""
    echo "Quick start: moonlight-ash stream        # stream Desktop"
    echo "             moonlight-ash stream <app>   # stream a specific app"
    moonlight "${MOONLIGHT_FLAGS[@]}" "$@"
    ;;
esac
