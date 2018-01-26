#

InterfaceModules+=("main")

declare optBackupType="auto"
declare optCypher="aes256cbc"
declare optRandomKeySize="256"
declare optCompressor="gzip"
declare optCompressionLevel="6"
declare optPublicKey=""
declare optSudoBinary="$(/usr/bin/env sudo)"
declare argDestinationUrl=""

function main:listOptions {
    println "full"
    println "incremental"
    println "auto"
    println "public-key:"
    println "cypher:"
    println "random-key-size:"
    println "compressor:"
    println "compression-level:"
    println "sudo-binary:"
}

function main:processOptions {
    case "$1" in
        --full)              optBackupType="full";;
        --incremental)       optBackupType="incremental";;
        --auto)              optBackupType="auto";;
        --public-key)        optPublicKey="$2";;
        --cypher)            optCyper="$2";;
        --random-key-size)   optRandomKeySize="$2";;
        --comspressor)       optCompressor="$2";;
        --compression-level) optCompressionLevel="$2";;
        --sudo-binary)       optSudoBinary="$2";;
        *) return 1;;
    esac

    return 0
}

function main:printHelp {
    local context="$1"
    case "$context" in
        --usage)
        printMultiline "
            |   $ProjectName --help
            |   $ProjectName push [OPTIONS] SUBVOLUME SNAPSHOT_DIR ARCHIVE
            |   $ProjectName pull [OPTIONS] SUBVOLUME ARCHIVE_DIR
            |   $ProjectName verify [OPTIONS] ARCHIVE/<SNAPSHOT_SUBDIR>
            ";;

        --arguments)
        printMultiline "
            |   SUBVOLUME
            |   SNAPSHOT_DIR
            |   ARCHIVE_DIR
            |   <SNAPSHOT_SUBDIR>
            ";;

        --options)
        printMultiline "
            | Common options:
            |   --tmp-prefix=DIR
            |
            | Options for backup command:
            |   --full
            |       Always do full backup. If previous snapshot still exists in
            |       SNAPSHOT_DIR, it will be replaced *after* all backup actions
            |       (including checksum verification, if requested) finish
            |       successfully.
            |   --incremental
            |       Always do incremental backup. If there is no previous snapshot
            |       available in SNAPSHOT_DIR, backup will be aborted with an error.
            |   --auto
            |       Automatically decide whether do full or incremental backup. If
            |       no previous snapshot is available, full backup is always chosen.
            |       Otherwise, it's incremental unless --max-incremental-* options
            |       prescribe the opposite.
            |   --max-incrementals-in-row N
            |       When working with --auto, ensure that there is no more than N
            |       incremental backups in a row. If the limit is exceeded, do
            |       full backup instead.
            |   --max-incrementals-size SIZE
            |       (Not implemented yet.)
            |   --verify-checksums
            |   --public-key=FILE
            |   --cypher=NAME
            |   --compressor=NAME
            |   --compression-level=NUM
            |   --random-key-size=NUM
            |   --chunk-size=SIZE
            |   --sudo-binary=PATH
            ";;

        *) abort 1 "It's a bug";;
    esac
}

function main:validateOptions {
    if ! [[ "$optCompressor" =~ ^(gzip|bzip|lzma)$ ]]; then
        abort 1 "compressor must be one of: gzip, bzip, lzma"
    fi

    if ! (( $optCompressionLevel >= 1 && $optCompressionLevel <= 9 )); then
        abort 1 "compression level must be in range [1, 9]"
    fi

    if ! [ -x "$optSudoBinary" ]; then
        abort 1 "sudo binary must exist and be executable"
    fi
}

function main:listCommands {
    println "push"
    println "pull"
    println "verify"
}

function main:command:push {
    abort 1 "Not implemented yet"
}

function main:command:pull {
    abort 1 "Not implemented yet"
}

function main:command:verify {
    abort 1 "Not implemented yet"
}
