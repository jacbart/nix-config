#!/usr/bin/env sh

set -eu
set -f # disable globbing
export IFS=' '

echo "Uploading paths" "$OUT_PATHS"
exec nix copy --to "s3://nix-cache?endpoint=s3.meep.sh" "$OUT_PATHS"
