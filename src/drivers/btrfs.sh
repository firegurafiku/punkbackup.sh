
function driver:btrfs:formSnapshotName { # SUFFIX
    println "$Subvolume@$1"
}

function driver:btrfs:hasSnapshot {
    [ -d "$1" ]
}

function driver:btrfs:createSnapshot { # PATH -> PATH
    echo sudo btrfs snapshot "$Subvolume" "$1"
}

function driver:btrfs:removeSnapshot { # PATH
    echo sudo btrfs snapshot delete "$1"
}

function driver:btrfs:sendFullSnapshot { # PATH
    dd bs=1M count=100 if=/dev/urandom 
}

function driver:btrfs:sendIncrementalSnapshot { # PATH PATH
    echo sudo btrfs send -i"$2" -- "$1"
}
