# Local filesystem backup provider.

ProviderModules+=("localfs")
DefaultProvider="localfs"

function localfs:printUsage { true; }
function localfs:initialize { true; }
function localfs:finalize { true; }
function localfs:listCommands { true; }
function localfs:listOptions { true; }
function localfs:validateOptions { true; }

function localfs:listDirectoryContents { # remote_path
    local fullpath="$(destinationFullPath "$1")"
    local file
    for file in "$fullpath"/*; do
        println "$(destinationRelPath "$file")"
    done
}

function localfs:isDirectory { # remote_path
    test -d "$(destinationFullPath "$1")"
}

function localfs:isRegularFile { # remote_path
    test -f "$(destinationFullPath "$1")"
}

function localfs:pushFile { # local remote
    local localPath="$1"
    local remotePath="$(destinationFullPath "$2")"
    cp "$localPath" "$remotePath"
}

function localfs:pullFile { # local remote
    local localPath="$1"
    local remotePath="$(destinationFullPath "$2")"
    cp "$remotePath" "$localPath"
}

function localfs:calcMD5 { # remote
    local remotePath="$(destinationFullPath "$2")"
    local result
    md5sum "$remotePath" | read -r result
    println "$result"
}

function localfs:calcSHA1 { # remote
    local remotePath="$(destinationFullPath "$2")"
    local result
    sha1sum "$remotePath" | read -r result
    println "$result"
}
