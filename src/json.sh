# This code implements a simplified streaming JSON parser.

function json:printProperties {
    # These are pseudo-global variables, freely available
    # for all nested functions in current call hierarchy.
    # This is how shell treats locals.
    local jsonText="$1"
    local jsonPath=""
    local jsonExtractedValue=""
    local jsonExtractedType=""

    json@processValue
}

function json@dumpPair {
    printf "%s\t%s\t%s\n" \
        "$jsonPath" "$jsonExtractedType" "$jsonExtractedValue"
}

function json@processValue {
    json@skipWhitespaces

    local firstCh="${jsonText::1}"
    case "$firstCh" in
        "[")
            json@processArray || return 1
            ;;

        "{")
            json@processObject || return 1
            ;;

        '"')
            json@extractString || return 1
            json@dumpPair
            ;;

        [0-9-])
            json@extractInteger || json@extractNumber || return 1
            json@dumpPair
            ;;

        *)
            json@extractBool || json@extractNull || return 1
            json@dumpPair
            return 1
    esac

    return 0
}

function json@processArray {
    json@skipDelimiter "[" || return 1
    if json@skipDelimiter "]"; then
        return 0
    fi

    local path="$jsonPath"
    local idx=0
    while true; do
        jsonPath="$path.$idx"
        json@processValue || return 1

        if json@skipDelimiter ","; then
            (( idx+=1 ))
            continue
        fi

        if json@skipDelimiter "]"; then
            break
        fi

        return 1
    done

    return 0
}

function json@processObject {
    json@skipDelimiter "{" || return 1
    if json@skipDelimiter "}"; then
        return 0
    fi

    local path="$jsonPath"
    local key
    while true; do
        json@extractString || return 1
        key="$jsonExtractedValue"

        json@skipDelimiter ":" || return 1
        jsonPath="$path.$key"

        json@processValue || return 1

        if json@skipDelimiter ","; then
            continue
        fi

        if json@skipDelimiter "}"; then
            break
        fi

        return 1
    done

    return 0
}

function json@skipWhitespaces {
    if [[ "$jsonText" =~ ^([[:space:]]+) ]]; then
        local match="${BASH_REMATCH[1]}"
        local matchLen="${#match}"

        jsonText="${jsonText:matchLen}"
    fi

    return 0
}

function json@skipDelimiter {
    local prefix="$1"
    local prefixLen="${#prefix}"

    json@skipWhitespaces

    if [[ "${jsonText::prefixLen}" == "$prefix" ]]; then
        jsonText="${jsonText:prefixLen}"
        return 0
    fi

    return 1
}

function json@extractString {
    json@skipWhitespaces

    if [[ "$jsonText" =~ ^'"'(([^\"\\$'\n']|\\[\"\\bfnrt/]|\\u[0-9a-fA-F]{4})*)\" ]]
    then
        local match="${BASH_REMATCH[1]}"
        local matchLen="${#match}"

        jsonExtractedValue="$match"
        jsonExtractedType="string"
        jsonText="${jsonText:matchLen+2}"
        return 0
    fi

    return 1
}

function json@extractInteger {
    json@skipWhitespaces

    if [[ "$jsonText" =~ ^-?[0-9]+ ]]; then
        local match="${BASH_REMATCH[0]}"
        local matchLen="${#match}"

        jsonExtractedValue="$match"
        jsonExtractedType="integer"
        jsonText="${jsonText:matchLen}"
        return 0
    fi

    return 1
}

function json@extractNumber {
    json@skipWhitespaces

    if [[ "$jsonText" =~ ^-?[0-9]+('.'[0-9]*)?([eE][+-]?[0-9]+)? ]]; then
        local match="${BASH_REMATCH[0]}"
        local matchLen="${#match}"

        jsonExtractedValue="$match"
        jsonExtractedType="number"
        jsonText="${jsonText:matchLen}"
        return 0
    fi

    return 1
}

function json@extractBool {
    json@skipWhitespaces

    if [[ "$jsonText" =~ ^(true|false) ]]; then
        local match="${BASH_REMATCH[1]}"
        local matchLen="${#match}"

        jsonExtractedValue="$match"
        jsonExtractedType="bool"
        jsonText="${jsonText:matchLen}"
        return 0
    fi

    return 1
}

function json@extractNull {
    json@skipWhitespaces

    if [[ "$jsonText" =~ ^null ]]; then
        jsonExtractedValue="null"
        jsonExtractedType="null"
        jsonText="${jsonText:4}"
        return 0
    fi

    return 1
}
