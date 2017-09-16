# Overall entrypoint.

function entrypoint {
    if [[ "$#" -eq 0 ]]; then
        options:printUsage
        exit
    fi

    if [[ "$#" -eq 1 && "$1" =~ ^(-h|--help)$ ]]; then
        options:printHelp
        exit
    fi

    local command="$1"
    shift

    # Option parsing will exit if something went wrong.
    options:parseOptions "$@"

    local module
    for module in "${InterfaceModules[@]}"; do
        local moduleCommand
        while IFS=$'\n' read -r moduleCommand; do
            if [[ "$moduleCommand" == "$command" ]]; then
                local err=0
                $module:command:$command || err="$?"
                exit "$err"
            fi
        done < <($module:listCommands)
    done

    abort 1 "Unsupported command '$command'"
}
