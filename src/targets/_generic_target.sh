
declare -a AvailableTargets=()
declare Target
declare RemoteUrl
declare RemoteProto
declare RemotePath
declare RemoteRelPath
declare RemoteSelPath

function target:initializeForUrl {
    local url="$1"
    local target
    for target in "${RegisteredTargets[@]}"; do
        if [[ "$url" =~ ^"$target:/"(.+)$ ]]; then
            Target="$target"
	    RemoteProto="$target://"
	    RemoteUrl="$url"
	    RemotePath="${BASH_REMATCH[1]}"
            target:selectRelPath "/"
            return
        fi
    done

    if [[ "$url" =~ ^/ ]]; then
	Target="target:file"
	RemoteProto="file://"
	RemoteUrl="file://$url"
	RemotePath="$url"
        target:selectRelPath "/"
	return
    fi
    
    abort 1 "Backup target protocol unsupported"
}

function target:selectRelPath {
    RemoteRelPath="$1"
    RemoteSelPath="$RemotePath/$1"
}

function target:listFiles {
    ${Target}:listFiles "$@"
}

function target:listDirs {
    ${Target}:listDirs "$@"
}

function target:makeDir {
    ${Target}:makeDir "$@"
}

function target:removeDir {
    ${Target}:removeDir "$@"
}

function target:pushFile { # local remote
    ${Target}:pushFile "$@"
}

function target:pullFile { # local remote
    ${Target}:pullFile "$@"
}

function target:removeFile {
    ${Target}:removeFile "$@"
}

function target:calcMD5 { # remote
    ${Target}:calcMD5 "$@"
}

function target:calcSHA1 { # remote
    ${Target}:calcSHA1 "$@"
}
