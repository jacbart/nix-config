{ pkgs }:
pkgs.writeShellApplication {
  name = "summarize-commit";
  runtimeInputs = with pkgs; [
    git
    gnugrep
    gawk
    gnused
    coreutils
    nix
  ];
  text = ''
    set -euo pipefail

    diff="$(git diff --cached | head -n 200)"
    if [ -z "$diff" ]; then
      echo "No staged diff found." >&2
      exit 1
    fi

    nix shell nixpkgs#llama-cpp --command llama-completion \
      -hf 'unsloth/Qwen3-0.6B-GGUF:Q5_K_M' \
      -p "Summarize the following git diff into a SINGLE conventional commit message (format: 'type: description') under 72 characters. Use one type only: feat, fix, refactor, perf, style, test, docs, build, ops, chore:\n\n$diff" \
      --single-turn 2>/dev/null \
      | grep -E '^(feat|fix|refactor|perf|style|test|docs|build|ops|chore):' \
      | sed 's/`//g; s/\[end of text\].*//'
  '';
}
