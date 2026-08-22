#!/usr/bin/env bash
# Launch Caves of Qud x86_64 build on aarch64 via box64.
#
# The itch.io Linux payload unpacks to a directory containing
#   - CoQ.x86_64     (the actual x86_64 ELF executable)
#   - UnityPlayer.so (the Unity engine shared object it dlopens)
#   - CoQ_Data/      (game assets)
#
# Two library sets are baked into this script at derivation time — see
# the `@X86_LIBS@` / `@NATIVE_LIBS@` placeholders, which `default.nix`
# replaces with real shell assignments:
#
#   - X86_LIB_ROOTS: cross x86_64 glibc/libgcc from the `pkgs.x86`
#     overlay (modules/flake/overlays.nix), used by box64 for the
#     emulated side (BOX64_LD_LIBRARY_PATH).
#   - NATIVE_LIB_ROOTS: native aarch64 libs (X11, wayland, GL, zlib,
#     audio...) that box64 wraps via native dlopen by soname. NixOS has
#     no /lib or ld.so.cache, so these must be on LD_LIBRARY_PATH or
#     every wrapped lib fails to init ("The selected window backend is
#     (null)", "Failed to load mono").
#
# So the wrapper is fully self-contained: it does not read
# /etc/ld.so.conf.d, does not rely on box64's --lib-path (which 0.4.2
# does not support), and does not need a nixos-rebuild to operate.
#
# Env:
#   COQ_DIR    directory containing the unpacked game
#              (default: ~/.local/games/cavesofqud)
#   COQ_BIN    override the launcher binary path explicitly
#   BOX64_LOG  box64 log level (0=quiet, 1=info, 2=debug; default 1)
set -euo pipefail

GAME_DIR="${COQ_DIR:-$HOME/.local/games/cavesofqud}"

if [[ ! -d "$GAME_DIR" ]]; then
  echo "coq: game directory not found: $GAME_DIR" >&2
  echo "coq: unpack the itch.io Linux (x86_64) build there, or set COQ_DIR." >&2
  exit 1
fi

BIN="${COQ_BIN:-}"

# The itch.io build ships an explicit x86_64 launcher executable.
if [[ -z "$BIN" && -x "$GAME_DIR/CoQ.x86_64" ]]; then
  BIN="$GAME_DIR/CoQ.x86_64"
fi

# Fallback: first executable in the dir that is not a shared library.
# (We keep the explicit preference above so we always pick CoQ.x86_64
# when it exists, and only fall back if the user renames it.)
if [[ -z "$BIN" ]]; then
  for f in "$GAME_DIR"/*; do
    [[ -f "$f" && -x "$f" ]] || continue
    case "$(basename "$f")" in *.so|*.so.*) continue ;; esac
    if [[ "$(head -c4 "$f" 2>/dev/null)" == $'\x7fELF' ]]; then
      BIN="$f"
      break
    fi
  done
fi

if [[ -z "$BIN" || ! -x "$BIN" ]]; then
  echo "coq: no launcher found in $GAME_DIR" >&2
  ls -la "$GAME_DIR" >&2
  exit 1
fi

# ---------------------------------------------------------------------
# Library store-roots, baked in at derivation time.
#
# `default.nix` replaces the `@X86_LIBS@` / `@NATIVE_LIBS@` placeholders
# with real shell assignments: <VAR>="/nix/store/.../lib ...". The values
# are space-separated lists of store-roots. If for some reason the
# placeholders were not substituted (e.g. you're reading this file
# directly out of the source tree), both fall back to empty and box64
# will still work, just without the library fallbacks.
# ---------------------------------------------------------------------
@X86_LIBS@
@NATIVE_LIBS@
: "${X86_LIB_ROOTS:=}"
: "${NATIVE_LIB_ROOTS:=}"

# Convert the space-separated lists to colon-separated.
X86_LIBS=""
if [[ -n "$X86_LIB_ROOTS" ]]; then
  for _d in ${X86_LIB_ROOTS}; do
    X86_LIBS="${X86_LIBS:+$X86_LIBS:}$_d"
  done
fi

NATIVE_LIBS=""
if [[ -n "$NATIVE_LIB_ROOTS" ]]; then
  for _d in ${NATIVE_LIB_ROOTS}; do
    NATIVE_LIBS="${NATIVE_LIBS:+$NATIVE_LIBS:}$_d"
  done
fi

export BOX64_LOG="${BOX64_LOG:-1}"
# Conservative dynarec settings: without these the game SIGSEGVs in the
# mono runtime during input-manager init (box64 already auto-disables
# BIGBLOCK and enables STRONGMEM when it detects MonoBleedingEdge, but
# that alone is not enough for Unity 6000.x under emulation).
: "${BOX64_DYNAREC_SAFEFLAGS:=2}"
: "${BOX64_DYNAREC_FASTNAN:=0}"
: "${BOX64_DYNAREC_FASTROUND:=0}"
export BOX64_DYNAREC_SAFEFLAGS BOX64_DYNAREC_FASTNAN BOX64_DYNAREC_FASTROUND
# LD_LIBRARY_PATH is for box64's *native* (wrapped) dlopens — the
# aarch64 X11/wayland/GL/audio libs. The game dir and x86_64 roots go
# on BOX64_LD_LIBRARY_PATH (emulated lookups) instead, so a native
# dlopen can never pick up a wrong-ELF-class .so from the game dir.
# Prepend, not replace, so any user-set values survive.
export LD_LIBRARY_PATH="${NATIVE_LIBS}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export BOX64_LD_LIBRARY_PATH="${GAME_DIR}${X86_LIBS:+:$X86_LIBS}${BOX64_LD_LIBRARY_PATH:+:$BOX64_LD_LIBRARY_PATH}"

echo "coq: running $BIN under box64"

exec box64 "$BIN" "$@"
