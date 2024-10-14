#!/usr/bin/env zsh

set +e  # Disable errexit
set +u  # Disable nounset
set +o pipefail  # Disable pipefail

function ensure_env() {
    if [ -z "${EDITOR}" ]; then
        echo "EDITOR is not set"
        exit 1
    fi
}

function open_page() {
    page=$1
    if [ ! -d "${HOME}/workspace/journal" ]; then
        mkdir -p "${HOME}/workspace/journal"
    fi
    $EDITOR "$HOME"/workspace/journal/"$page".md
}

function main() {
    ensure_env
    if [ $# -gt 1 ]; then
        echo "only accepts <= 1 args: 'YYYY-MM-DD'"
    elif [ $# -lt 1 ]; then
        today=$(date "+%Y-%m-%d")
        open_page "$today"
    else
        open_page "$1"
    fi
}

main "$@"