
declare Driver
declare Subvolume

function driver:initializeForPath {
    Driver="driver:btrfs"
    Subvolume="$1"
}

function driver:formSnapshotName { # SUFFIX
    ${Driver}:formSnapshotName "$@"
}

function driver:hasSnapshot {
    ${Driver}:hasSnapshot "$@"
}

function driver:createSnapshot { # PATH -> PATH
    ${Driver}:createSnapshot "$@"
}

function driver:removeSnapshot { # PATH
    ${Driver}:removeSnapshot "$@"
}

function driver:sendFullSnapshot { # PATH
    ${Driver}:sendFullSnapshot "$@"
}

function driver:sendIncrementalSnapshot { # PATH PATH
    ${Driver}:sendIncrementalSnapshot "$@"
}
