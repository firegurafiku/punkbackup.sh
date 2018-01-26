# Local filesystem backup provider.

RegisteredTargets+=("target:file")

function target:file:listFiles {
    local fn
    for fn in "$RemoteSelPath"/*; do
        if [ -f "$fn" ]; then
            println "$(basename "$fn")"
	fi
    done
}

function target:file:listDirs {
    local fn
    for fn in "$RemoteSelPath"/*; do
        if [ -d "$fn" ]; then
            println "$(basename "$fn")"
	fi
    done
}

function target:file:makeDir {
    mkdir -p -- "$RemoteSelPath/$1"
}

function target:file:removeDir {
    echo rm -rf -- "$RemoteSelPath/$1"
}

function target:file:pushFile { # local remote
    cp --target-directory "$RemoteSelPath" -- "$1"
}

function target:file:pullFile { # local remote
    cp --target-directory "$PWD" -- "$RemoteSelPath/$1"
}

function target:file:removeFile {
    echo rm -- "$RemoteSelPath/$1"
}

function target:file:calcMD5 { # remote
    local result
    md5sum "$RemoteSelPath/$1" | read -r result
    println "$result"
}

function target:file:calcSHA1 { # remote
    local result
    sha1sum "$RemoteSelPath/$1" | read -r result
    println "$result"
}
