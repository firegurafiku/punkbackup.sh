# Common routines useful for testing

function runOnEachFile {
    local -a fixedArgs=()
    local fixedArgsCount=0
    local arg
    for arg; do
        if [[ "$arg" == "--" ]]; then
            break
        fi

        fixedArgs+=("$arg")
        (( fixedArgsCount+=1 ))
    done

    shift "$((fixedArgsCount+1))"

    local file
    local success="y"
    for file; do
        if "${fixedArgs[@]}" "$file"; then
            echo "PASS -- ${fixedArgs[@]} $(basename "$file")"
        else
            echo "FAIL -- ${fixedArgs[@]} $(basename "$file")"
            success="n"
        fi
    done

    if [[ "$success" == "y" ]]; then
        return 0
    else
        return 1
    fi
}
