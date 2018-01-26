InterfaceModules+=("common")

declare TempDir
declare optVerbose="n"
declare optDebug="n"
declare optSystemTmp="/tmp"
declare optSudoBinary="$(which sudo)"

function common:listOptions {
    println "verbose"
    println "debug"
    println "system-tmp:"
    println "sudo-binary:"
}

function common:processOptions {
    case "$1" in
	--verbose)           optVerbose="y";;
	--debug)             optDebug="y";;
        --system-tmp)        optSystemTmp="$2";;
        --sudo-binary)       optSudoBinary="$2";;
        *) return 1;;
    esac

    return 0
}

function common:validateOptions {
    [ -d "$optSystemTmp" ] ||
        abort 1 "--system-tmp: directory must exist"
    [ -x "$optSudoBinary" ] ||
        abort 1 "--sudo-binary: file must exist and be executable"
}

function common:printHelp {
    case "$1" in
        --usage) ;;
	--arguments) ;;

        --options)
        printMultiline "
            | Common options:
            |   --tmp-prefix=DIR
            |   --sudo-binary=PATH
            ";;

        *) abort 1 "a bug in 'common:printHelp'";;
    esac
}

function common:listCommands {
    true;
}

function common:createTempDir {
    TempDir="$(mktemp -d --tmpdir="$optSystemTmp" -- "punkbackup.XXXXXXXXX")"
}

function common:cleanupTempDir {
    rm -rf -- "$TempDir"
}

function common:withSudo {
    if [ -z "$optSudoBinary" ]; then
	"$@"
    else
        "$optSudoBinary" "$@"
    fi
}

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

function die {
    abort 1
}
