# Parse options. Unfortunately, there is no easy way in bash to split
# general options from command-specific options. The best we can do
# is to maintain a global list of option variables.

declare -a PositionalArgs

function options:parseOptions {
    local getoptVer=0
    getopt --test > /dev/null || getoptVer="$?"
    if [[ "$getoptVer" -ne 4 ]]; then
        abort 1 "The system's 'getopt' seems to be unsupported."
    fi

    #
    local IFS=$'\n'

    local -a longOptionsSpecs=()
    local -a longOptions=()
    local -A longOptionsHasArg

    local module
    for module in "${InterfaceModules[@]}"; do
        local optionSpec
        while read -r optionSpec; do
            if ! [[ "$optionSpec" =~ ^([a-zA-Z][a-zA-Z0-9-]*)(:?)$ ]]; then
                abort 1 "Illegal option format"
            fi

            local optionName="${BASH_REMATCH[1]}"
            if [[ "${BASH_REMATCH[2]}" == ":" ]]; then
                longOptionsHasArg["$optionName"]="y"
            else
                longOptionsHasArg["$optionName"]="n"
            fi

            longOptionsSpecs+=("$optionSpec")
            longOptions+=("$optionName")
        done < <($module:listOptions)
    done

    local parsed="$(set +e; getopt \
                             --name="$ProjectName" \
                             --longoptions="${longOptionsSpecs[*]}" \
                             -- "$ProjectName" "$@")" err=$?

    # If options were wrong, getopt has already complained
    # about them to stdout, so just exit.
    if [[ "$err" != 0 ]]; then
        exit 2
    fi

    eval set -- "$parsed"
    while true; do
        case "$1" in
            --[a-z]*)
                [[ "$1" =~ ^--([a-zA-Z][a-zA-Z0-9-]*)$ ]]

                local optionName="${BASH_REMATCH[1]}"
                local hasArgument="n"
                if [[ "${longOptionsHasArg[$optionName]}" == "y" ]]; then
                    hasArgument="y"
                fi

                local found="n"
                for module in "${InterfaceModules[@]}"; do
                    local arg=""
                    if [[ "$hasArgument" == "y" ]]; then
                        arg="$2"
                    fi

                    if $module:processOptions "--$optionName" "$arg"; then
                        found="y"
                        [[ "$hasArgument" == "y" ]] && shift 2 || shift
                        break
                    fi
                done

                if [[ "$found" == "n" ]]; then
                    abort 1 "Something bad happened"
                fi
                ;;

            --) shift ; break ;;
            *) abort 3 "Programming error" ;;
        esac
    done

    PositionalArgs=("$@")
}

function options:printUsage {
    println "Usage:"
    local module
    for module in "${InterfaceModules[@]}"; do
        $module:printHelp --usage
    done
}

function options:printHelp {
    options:printUsage
    skipln

    println "Arguments:"
    local module
    for module in "${InterfaceModules[@]}"; do
        $module:printHelp --arguments
    done
    skipln

    local module
    for module in "${InterfaceModules[@]}"; do
        $module:printHelp --options
        skipln
    done
}
