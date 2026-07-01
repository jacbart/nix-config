#!/usr/bin/env bash
set -euo pipefail

# hx-go-tags — manage gopls buildFlags (-tags) for helix, per-project, rebuild-free.
#
# Helix deep-merges a per-project .helix/languages.toml over the global
# (Nix-managed) config. We override only `language-server.gopls.config.buildFlags`,
# so every other gopls setting (gofumpt, analyses, hints, staticcheck, ...) stays
# as defined in modules/home/shell/tools/helix-langs.nix.

FILE=".helix/languages.toml"

# dasel v3 query: upsert buildFlags, auto-vivifying intermediate tables.
# Spread+explicit override only works as an *assignment value* (not as the root
# expression), so we use chained variable assignments. `??{}` supplies an empty
# map when an intermediate key is missing, which the spread then fills in.
# __TAGS__ is substituted with the validated, comma-joined tag list.
UPSERT_QUERY='$ls=$root["language-server"]??{};$gopls=$ls["gopls"]??{};$cfg=$gopls["config"]??{};$cfg={$cfg...,"buildFlags":["-tags=__TAGS__"]};$gopls={$gopls...,"config":$cfg};$ls={$ls...,"gopls":$gopls};$root={$root...,"language-server":$ls};$root'
KEY_QUERY='$root["language-server"]["gopls"]["config"]["buildFlags"]??""'

usage() {
  cat <<'EOF'
hx-go-tags — manage gopls buildFlags (-tags) for helix, per-project, no rebuild.

Usage:
  hx-go-tags TAGS...        Set build tags (comma- and/or space-separated).
                              e.g. hx-go-tags stub integration
                                   hx-go-tags stub,integration
  hx-go-tags                Print the current per-project override (if any).
  hx-go-tags --pick         Prompt for tags interactively (requires a TTY;
                              intended for use via a tmux popup from helix).
  hx-go-tags --clear        Remove the per-project buildFlags override.
  hx-go-tags --help|-h      Show this help.

Writes/updates .helix/languages.toml in the current directory. Helix deep-merges
this over your global (Nix-managed) config, so only buildFlags is overridden —
all other gopls settings are preserved.

After setting or clearing, restart helix so gopls re-initializes with the new tags.
EOF
}

# Join args into a validated, deduped, comma-joined tag list.
# Accepts both "stub integration" and "stub,integration" (and mixed).
join_tags() {
  local all=()
  local arg
  for arg in "$@"; do
    local IFS=,
    read -ra parts <<< "$arg"
    all+=("${parts[@]}")
  done
  local seen="" result="" t
  for t in "${all[@]}"; do
    # trim leading/trailing whitespace
    t="${t#"${t%%[![:space:]]*}"}"
    t="${t%"${t##*[![:space:]]}"}"
    [[ -z "$t" ]] && continue
    # validate: Go build tags are identifiers; allow [A-Za-z0-9_.!] (+ optional leading !)
    if [[ ! "$t" =~ ^!?[A-Za-z0-9_.]+$ ]]; then
      echo "hx-go-tags: invalid tag '$t' (allowed: letters, digits, '_', '.', optional leading '!')" >&2
      exit 1
    fi
    if [[ ",$seen," != *",$t,"* ]]; then
      seen="$seen,$t"
      result="${result:+$result,}$t"
    fi
  done
  printf '%s' "$result"
}

set_tags() {
  local tags="$1"
  mkdir -p .helix
  if [[ ! -f "$FILE" ]] || [[ ! -s "$FILE" ]]; then
    # no existing file (or empty): write fresh, nothing to preserve.
    printf '[language-server.gopls.config]\nbuildFlags = ["-tags=%s"]\n' "$tags" > "$FILE"
    return
  fi
  local q="${UPSERT_QUERY/__TAGS__/$tags}"
  dasel -i toml -o toml --root "$q" < "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
}

# Print the tags from the per-project override (without the -tags= prefix),
# or "no override" when absent.
get_tags() {
  if [[ ! -f "$FILE" ]] || [[ ! -s "$FILE" ]]; then
    echo "no override"
    return
  fi
  local raw
  raw="$(dasel -i toml "$KEY_QUERY" < "$FILE" 2>/dev/null || true)"
  if [[ -z "$raw" || "$raw" == "''" ]]; then
    echo "no override"
    return
  fi
  # raw is like ['-tags=stub,integration']; take first element, strip quotes + -tags=
  local val
  val="$(dasel -i toml '$root["language-server"]["gopls"]["config"]["buildFlags"][0]??"none"' < "$FILE" 2>/dev/null || true)"
  # val is quoted: '-tags=...' or "none"
  val="${val#\'}"
  val="${val%\'}"
  if [[ "$val" == "none" || -z "$val" ]]; then
    echo "no override"
  else
    printf '%s\n' "${val#-tags=}"
  fi
}

clear_tags() {
  if [[ ! -f "$FILE" ]] || [[ ! -s "$FILE" ]]; then
    echo "no override"
    return
  fi
  local raw
  raw="$(dasel -i toml "$KEY_QUERY" < "$FILE" 2>/dev/null || true)"
  if [[ -z "$raw" || "$raw" == "''" ]]; then
    echo "no override"
    return
  fi
  dasel -i toml -o toml --root '$root["language-server"]["gopls"]["config"]["buildFlags"]=null' < "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  echo "cleared"
}

# Interactive prompt for tags. Intended for use via a tmux popup from helix
# (which provides a real TTY). Shows the current override, reads one line,
# splits on commas+whitespace, validates, and sets. Blank input cancels.
# Does not print a "restart helix" reminder — the helix keybind chains
# :lsp-restart after the popup closes.
pick_tags() {
  if [[ ! -t 0 ]]; then
    echo "hx-go-tags: --pick requires a TTY (run via tmux popup from helix)" >&2
    exit 1
  fi
  echo "current: $(get_tags)"
  local input
  read -rp "Build tags (comma/space separated, blank to cancel): " input
  if [[ -z "$input" ]]; then
    echo "cancelled"
    return
  fi
  # split the line on commas and whitespace, then validate via join_tags
  local IFS=', '
  local -a parts
  read -ra parts <<< "$input"
  local tags
  tags="$(join_tags "${parts[@]}")"
  if [[ -z "$tags" ]]; then
    echo "hx-go-tags: no valid tags given" >&2
    exit 1
  fi
  set_tags "$tags"
  echo "set buildFlags = [\"-tags=$tags\"] in $FILE"
}

main() {
  case "${1:-}" in
    --help | -h)
      usage
      ;;
    --pick)
      pick_tags
      ;;
    --clear)
      clear_tags
      echo "restart helix to apply" >&2
      ;;
    "")
      get_tags
      ;;
    *)
      local tags
      tags="$(join_tags "$@")"
      if [[ -z "$tags" ]]; then
        echo "hx-go-tags: no tags given" >&2
        usage >&2
        exit 1
      fi
      set_tags "$tags"
      echo "set buildFlags = [\"-tags=$tags\"] in $FILE"
      echo "restart helix to apply" >&2
      ;;
  esac
}

main "$@"
