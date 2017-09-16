
declare -r ProjectName="punkbackup.sh"

declare -a InterfaceModules=()

declare -a ProviderModules=()

declare DefaultProvider

function skipln {
    printf "\n"
}

function println {
    local str
    for str in "$@" ; do
        printf "%s\n" "$str"
    done
}

function printMultiline {
    local IFS=$'\n'
    local lines=($1)

    local line
    for line in "${lines[@]}" ; do
        if [[ "$line" =~ ^[[:space:]]*$ ]] ; then
            continue
        fi

        if [[ "$line" =~ ^[[:space:]]*'|'$ ]] ; then
            printf "\n"
            continue
        fi

        if [[ "$line" =~ ^[[:space:]]*'| '(.*)$ ]] ; then
            printf "%s\n" "${BASH_REMATCH[1]}"
            continue
        fi

        abort 1 "Wrong string literal. This is a bug."
    done
}

function abort {
    local exitCode="$1"
    shift

    println "$@" 1>&2
    exit "$exitCode"
}
