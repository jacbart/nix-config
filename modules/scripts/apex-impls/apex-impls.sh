#!/usr/bin/env bash
set -euo pipefail

# apex-impls — find Apex classes implementing an interface / extending a class.
#
# Substitute for LSP goto-implementation: NO Apex language server implements
# textDocument/implementation (verified against apex-jorje 67.3.0 ServerCapabilities
# and the jar's class list; Salesforce's new TS server and apex-dev-tools/apex-ls
# lack it too). This greps declarations instead — Apex is case-insensitive, so
# the search is as well.

usage() {
  cat <<'EOF'
apex-impls — find Apex classes implementing an interface / extending a class.

Usage:
  apex-impls TypeName          List matches as file:line: declaration.
  apex-impls --pick TypeName   Pick a match with fzf; inside tmux, opens it in
                                 the helix pane (like scooter), else prints it.
  apex-impls --help|-h         Show this help.

Searches *.cls and *.trigger under the enclosing sfdx project root (nearest
directory containing sfdx-project.json), falling back to the current directory.
Matches `implements`/`extends` clauses, including ones spanning multiple lines.
EOF
}

PICK=0
TYPE=""
for arg in "$@"; do
  case "$arg" in
    --help | -h)
      usage
      exit 0
      ;;
    --pick)
      PICK=1
      ;;
    -*)
      echo "apex-impls: unknown option '$arg'" >&2
      usage >&2
      exit 1
      ;;
    *)
      TYPE="$arg"
      ;;
  esac
done

if [[ -z "$TYPE" ]]; then
  usage >&2
  exit 1
fi
if [[ ! "$TYPE" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
  echo "apex-impls: '$TYPE' is not a valid Apex type name" >&2
  exit 1
fi

# Walk up to the sfdx project root so results cover the whole project no matter
# where we're invoked from.
root="$PWD"
dir="$PWD"
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/sfdx-project.json" ]]; then
    root="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done

# -U: declarations may wrap across lines between the keyword and the type name.
# [^{]* stops the match at the class body so `extends Foo { ... uses Bar }`
# doesn't false-positive on Bar.
matches="$(
  rg --line-number --no-heading --with-filename -U \
    --glob '*.cls' --glob '*.trigger' \
    -e "(?is)\b(implements|extends)\b[^{]*\b${TYPE}\b" \
    "$root" || true
)"

if [[ -z "$matches" ]]; then
  echo "apex-impls: no implementations/extensions of '$TYPE' found under $root" >&2
  exit 1
fi

if [[ "$PICK" -eq 0 ]]; then
  printf '%s\n' "$matches"
  exit 0
fi

sel="$(printf '%s\n' "$matches" | fzf --prompt="impl of $TYPE> " --no-multi)" || exit 130
loc="$(printf '%s\n' "$sel" | awk -F: '{print $1 ":" $2}')"
if [[ -n "${TMUX_PANE:-}" ]]; then
  # Same trick as the scooter editor_open config: drive the helix instance in
  # the launching tmux pane.
  tmux send-keys -t "$TMUX_PANE" ":open \"$loc\"" Enter
else
  printf '%s\n' "$loc"
fi
