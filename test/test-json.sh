#!/bin/bash
set -o errexit
set -o nounset

source src/json.sh
source test/common.sh

function testInvalidSample {
    local filename="$1"
    local contents="$(<"$filename")"
    local err=0
    json:printProperties "$contents" >/dev/null || err=$?

    if [[ "$err" -eq 41 ]]; then
        return 0
    else
        return 1
    fi
}

function testValidSample {
    local filename="$1"
    local contents="$(<"$filename")"
    local err=0
    json:printProperties "$contents" >/dev/null || err=$?

    if [[ "$err" -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

declare err=0
runOnEachFile testInvalidSample \
        -- test/json-samples/thirdparty/invalid-*.json || err=$?

runOnEachFile testValidSample \
        -- test/json-samples/thirdparty/valid-*.json || err=$?

exit "$err"
