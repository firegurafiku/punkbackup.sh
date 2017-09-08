#!/bin/bash
set -o errexit
set -o nounset

source src/json.sh

function test:json@testInvalidSample {
    local filename="$1"
    local contents="$(<"$filename")"
    local err=0
    json:printProperties "$contents" >/dev/null || err=$?

    if [[ "$err" -eq 41 ]]; then
        return 0
    fi

    return 1
}

declare filename
for filename in test/json-parser-samples/invalid-*.json; do
    if test:json@testInvalidSample "$filename"; then
        echo "PASS -- $filename"
    else
        echo "FAIL -- $filename"
    fi
done
