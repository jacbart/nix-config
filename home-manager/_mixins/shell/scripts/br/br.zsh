#!/usr/bin/env zsh

set +e  # Disable errexit
set +u  # Disable nounset
set +o pipefail  # Disable pipefail

# broot wrapper that executes the command it generates
br_func() {
        local cmd cmd_file code
        cmd_file=$(mktemp)
        if broot --outcmd "$cmd_file" "$@"
        then
                cmd=$(<"$cmd_file")
                command rm -f "$cmd_file"
                eval "$cmd"
        else
                code=$?
                command rm -f "$cmd_file"
                return "$code"
        fi
}

br_func "$@"