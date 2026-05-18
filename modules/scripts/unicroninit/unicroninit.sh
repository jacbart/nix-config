#!/usr/bin/env bash
set -euo pipefail

repoName=""
repoDesc=""
repoOwner=""

# ── Parse CLI args ─────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
  --name)
    repoName="$2"
    shift 2
    ;;
  --desc)
    repoDesc="$2"
    shift 2
    ;;
  --owner)
    repoOwner="$2"
    shift 2
    ;;
  *)
    gum style --foreground 196 "Unknown option: $1"
    exit 1
    ;;
  esac
done

# ── Auto-detect from current git repo ──────────────────────────────
if git rev-parse --git-dir &>/dev/null; then
  if [[ -z "$repoName" ]]; then
    repoName=$(basename "$(git rev-parse --show-toplevel)")
  fi

  if [[ -z "$repoOwner" ]]; then
    remoteUrl=$(git remote get-url origin 2>/dev/null || true)
    if [[ -n "$remoteUrl" ]]; then
      if [[ "$remoteUrl" =~ github\.com[/:]([^/]+)/([^/.]+) ]]; then
        detectedOwner="${BASH_REMATCH[1]}"
        detectedName="${BASH_REMATCH[2]}"
        [[ -z "$repoOwner" ]] && repoOwner="$detectedOwner"
        [[ -z "$repoName" ]] && repoName="$detectedName"
      fi
    fi
  fi
fi

# ── Interactive prompts for missing values ────────────────────────
gum style --foreground 212 --bold "Unicron Init"
gum style --foreground 240 "Initialize a bare repo on unicron and configure local remotes."
echo

if [[ -z "$repoName" ]]; then
  repoName=$(gum input --placeholder "my-repo" --prompt "Repo name: ")
fi

if [[ -z "$repoOwner" ]]; then
  repoOwner=$(gum input --placeholder "github-owner" --prompt "GitHub owner: ")
fi

if [[ -z "$repoDesc" ]]; then
  repoDesc=$(gum input --placeholder "optional description" --prompt "Description: ")
fi

# ── Validation / Confirmation ──────────────────────────────────────
if [[ -z "$repoName" || -z "$repoOwner" ]]; then
  gum style --foreground 196 "Repo name and owner are required."
  exit 1
fi

echo
gum style --bold "Configuration:"
gum style --foreground 240 "  Name:        $repoName"
gum style --foreground 240 "  Owner:       $repoOwner"
gum style --foreground 240 "  Description: ${repoDesc:-<none>}"
echo

if ! gum confirm "Create '$repoName' on unicron?"; then
  gum style --foreground 208 "Aborted."
  exit 0
fi

# ── Check if repo already exists on unicron ────────────────────────
if ssh unicron "test -d /git/$repoName" 2>/dev/null; then
  gum style --foreground 208 "Repo '$repoName' already exists on unicron."
  if ! gum confirm "Overwrite existing repo?"; then
    gum style --foreground 208 "Aborted."
    exit 0
  fi
  gum spin --title "Removing existing repo..." -- ssh unicron "sudo rm -rf /git/$repoName"
fi

# ── Create bare repo on unicron ────────────────────────────────────
gum spin --title "Creating bare repo on unicron..." -- \
  ssh unicron "sudo -u git git init --bare /git/$repoName"

gum spin --title "Setting description..." -- \
  ssh unicron "sudo -u git sh -c 'echo \"$repoDesc\" > /git/$repoName/description'"

gum spin --title "Setting ownership..." -- \
  ssh unicron "sudo chown -R jack:git /git/$repoName"

# ── Configure local git remotes ────────────────────────────────────
if ! git rev-parse --git-dir &>/dev/null; then
  gum style --foreground 208 "Not inside a git repository. Skipping remote configuration."
  gum style --foreground 46 "✓  Repo '$repoName' created on unicron."
  exit 0
fi

# Ensure origin remote exists
if ! git remote get-url origin &>/dev/null; then
  git remote add origin "https://github.com/$repoOwner/$repoName"
fi

# Set up push remotes: GitHub + cgit
git remote set-url --push origin "https://github.com/$repoOwner/$repoName"
git remote set-url --push --add origin "git@cgit.bbl.systems:$repoName"

echo
gum style --foreground 46 "✓  Success! Repo '$repoName' initialized on unicron."
gum style --foreground 240 "  Push URLs configured:"
git remote -v | grep "origin.*push" | while read -r line; do
  gum style --foreground 240 "    $line"
done
