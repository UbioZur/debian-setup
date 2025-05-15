#!/usr/bin/env bash
##  ~ UbioZur - https://github.com/UbioZur ~  ##

# Generate the final scripts for release if
# License: MIT | https://github.com/UbioZur/debian-setup/raw/main/LICENSE

# Fail Fast and cleanup
set -Eeuo pipefail
# trap cleanup SIGINT SIGTERM ERR EXIT
# trap cleanup EXIT

readonly SCRIPTDIR=$(dirname "$(realpath $0)")
readonly VERBOSE="1"

# Source the required libraries
source "$SCRIPTDIR/../libs/logs.bash"

generate() {
    local -r workingDirectory=${PWD}
    local -r scriptAmount="$(ls *.sh 2> /dev/null | wc -l 2> /dev/null)"
    local -r releaseFolder="${PWD}/release/"

    log "Working Directory: ${workingDirectory}" >&2
    [[ "0" == "${scriptAmount}" ]] && die "Could not find any \e[36m.sh\e[0m scripts in the working directory!" >&2
    log "Found ${scriptAmount} script(s) to process" >&2

    if [[ ! -d ${releaseFolder} ]]; then
        mkdir -p "${releaseFolder}"
        log "Release folder \e[36m${releaseFolder}\e[0m created" >&2
    fi

    local processed=0
    for script in *.sh; do
        local tmpFile=$(mktemp -q)
        local err="false";
        log "\e[33m\u2699  Processing script \e[36m${script}\e[0m"
        while IFS= read -r line; do
            if [[ "$line" =~ ^## ]]; then continue; fi
            if [[ "$line" =~ ^source[[:space:]]+([^[:space:]]+)$ ]] || [[ "$line" =~ ^\.[[:space:]]+([^[:space:]]+)$ ]]; then
                sourced_file="${BASH_REMATCH[1]}"
                if [[ ! -f "$sourced_file" ]]; then
                    err="true"
                    logError "\e[31m\u2717  Could not process script ${script}"
                    break
                fi
                cat "$sourced_file" | grep -v '^##'
                continue
            fi
            echo "$line"
        done < "$script" > "$tmpFile"
        if [[ $err == "true" ]]; then
            continue
        fi
        local dst="${releaseFolder}${script}"
        mv "$tmpFile" "$dst"
        chmod u+x "$dst"
        log "\e[32m\u2714  Script \e[36m${script}\e[0m\e[32m merged\e[0m".
        processed=$((processed+1))
    done
    log "Scripts handled: ${processed}"

    [[ "$processed" != "$scriptAmount" ]] && die "Couldn't make the release!" 1
    exit 0
}

generate
