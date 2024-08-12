br () {
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

j () {
        p=""
        if [ $# -lt 1 ]; then
                p="$(pwd)"
        elif [ $# -gt 1 ]; then
                echo "only one arg allowed"
        else
                p="$@"
        fi
        z "$p" || exit 1 && wait
        br
}
