#!/usr/bin/env bash
set -euo pipefail

# resolve — follow a command/path's symlink chain to the final real file,
# then print its `ls -l` listing. Portable (no ls-output parsing) and
# handles relative symlink targets (resolved against the link's own dir).

usage() {
  cat <<'EOF'
resolve — follow a symlink chain to the final real file.

Usage:
  resolve <command>   Resolve a command found in PATH (e.g. resolve fzf).
  resolve <path>      Resolve an existing file/symlink path directly.

Prints the `ls -l` listing of the final, non-symlink target.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi
if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

arg="$1"
# Accept either an existing path or a command name in PATH.
if [[ -e "$arg" || -L "$arg" ]]; then
  target="$arg"
else
  target="$(command -v "$arg" 2>/dev/null || true)"
  if [[ -z "$target" ]]; then
    echo "resolve: '$arg' not found in PATH or filesystem" >&2
    exit 1
  fi
fi

# Follow the symlink chain one link at a time. readlink gives the raw
# target as stored in the link; resolve relative targets against the
# link's own directory so `../foo` links work from any CWD.
while [[ -L "$target" ]]; do
  next="$(readlink "$target")"
  if [[ "$next" != /* ]]; then
    next="$(dirname "$target")/$next"
  fi
  target="$next"
done

if [[ ! -e "$target" ]]; then
  echo "resolve: chain ends at dangling target '$target'" >&2
  exit 1
fi

# Canonicalize the final path (resolves . and .. components introduced
# by relative symlink targets, without following any trailing symlink).
dir="$(cd -- "$(dirname -- "$target")" && pwd -P)"
target="$dir/$(basename -- "$target")"

dua "$target"
ls -lah "$dir"
