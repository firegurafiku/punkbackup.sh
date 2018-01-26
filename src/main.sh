#

InterfaceModules+=("main")

declare optBackupType="auto"
declare optCypher="aes256cbc"
declare optRandomKeySize="256"
declare optCompressor="gzip"
declare optCompressionLevel="6"
declare optPublicKey=""
declare optChunkSize="32M"

function main:listOptions {
    println "full"
    println "incremental"
    println "auto"
    println "public-key:"
    println "cypher:"
    println "random-key-size:"
    println "compressor:"
    println "compression-level:"
    println "chunk-size:"
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
        --chunk-size)        optChunkSize="$2";;
        *) return 1;;
    esac

    return 0
}

function main:validateOptions {
    [[ "$optCompressor" =~ ^(gzip|bzip|lzma)$ ]] ||
        abort 1 "compressor must be one of: gzip, bzip, lzma"
    (( $optCompressionLevel >= 1 && $optCompressionLevel <= 9 )) ||
        abort 1 "compression level must be in range [1, 9]"
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
            ";;

        *) abort 1 "It's a bug";;
    esac
}

function main:listCommands {
    println "push"
    println "pull"
    println "verify"
}

# ---


function main:command:push {
    driver:initializeForPath "$1"
    target:initializeForUrl "$2"
    local PrevSnapshot="$(driver:formSnapshotName "punkbackup-latest")"
    local CurrSnapshot="$(driver:formSnapshotName "punkbackup-current")"

    # Check if given remote path exists and can actually be accessed. 
    target:listDirs >/dev/null || die
 
    if driver:hasSnapshot "$CurrSnapshot"; then
	driver:removeSnapshot "$CurrSnapshot" || die
    fi

    driver:createSnapshot "$Subvolume" "$CurrSnapshot" || die

    local timestamp="$(date --iso-8601=seconds)"
    target:makeDir "$timestamp" || die
    target:selectRelPath "$timestamp" || die

    local t="$TempDir"
    mkfifo -- "$t/fifo" || die
    
    main@sendSnapshot | main@compress >"$t/fifo" &
    
    local chunkNo="0"
    truncate -s0 -- "$t/chunk.tmp"
    truncate -s0 -- "$t/CHECKSUMS.md5"
    truncate -s0 -- "$t/CHECKSUMS.sha1"

    local fd
    exec {fd}<"$t/fifo"
    while dd bs=1 count="$optChunkSize" of="$t/chunk.tmp" 0<&${fd} ; do
	if ! [ -s "$t/chunk.tmp" ]; then
	    break
	fi

	(( chunkNo = chunkNo + 1 ))
	local f="$(printf "chunk%04d" "$chunkNo")"
	println "Got: $f"

	#main@generateKey "$f.key"
	#main@encryptKey "$f.key" "$f.key.enc"
	#main@encryptChunk "$f.key" "chunk.tmp" "$f.enc"
	#md5sum  "$f.bin" >>"CHECKSUMS.md5"
	#sha1sum "$f.bin" >>"CHECKSUMS.sha1"

	#target:pushFile "$f.enc" || die
	#target:pushFile "$f.key.enc" || die
	#rm "$f.enc" "$f.key" "$f.key.enc"
    done

    target:pushFile "$t/CHECKSUMS.md5" || die
    target:pushFile "$t/CHECKSUMS.sha1" || die
    popd
}

function main@sendSnapshot {
    case "$optBackupType" in
	"full")
	    driver:sendFullSnapshot "$CurrSnapshot"
	    ;;
	
	"incremental")
	    driver:sendIncremental "$CurrSnapshot" "$PrevSnapshot"
	    ;;

	*)
            abort 2 "unsupported backup type"
	    ;;
    esac
}

function main@compress {
    "$optCompressor" "-$optCompressionLevel"
}

function main@generateKey { # KEYFILE
    local outFile="$1"
    openssl rand -base64 $(( $optRandomKeySize/8 )) -out "file:$outFile"
}

function main@encryptChunk { # KEYFILE CHUNK ENCCHUNK
    local keyFile="$1"
    local inFile="$2"
    local outFile="$3"
    openssl enc "-$optCypher" -salt \
        -in "file:$inFile" \
        -out "file:$outFile" \
	-pass "file:$keyFile"
}

function main@encryptKey { # KEYFILE ENCFILE
    local keyFile="$1"
    local encFile="$2"
    openssl rsautl -encrypt -inkey "$optPublicKey" -pubin \
            -in "file:$keyFile" \
            -out "file:$encFile"
}

function main:command:pull {
    abort 1 "Not implemented yet"
}

function main:command:verify {
    abort 1 "Not implemented yet"
}
