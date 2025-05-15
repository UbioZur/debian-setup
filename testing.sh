#!/usr/bin/env bash

# Setup Debian Testing Repositories
# License: MIT | https://github.com/UbioZur/debian-setup/raw/main/LICENSE

# Fail Fast and cleanup
set -Eeuo pipefail
# trap cleanup SIGINT SIGTERM ERR EXIT
trap cleanup EXIT


INFOLINESCOUNT=0

# Log the start of a task
taskStart() {
    local -r msg="$1"
    local -r icon="  \e[33m\u2699  "
    local -r clr="\e[0m"
    INFOLINESCOUNT=0
    [[ ! -v DEBUG ]] && printf "\e[?25l"
    printf "${icon}${msg}${clr}\n"
}

# Log the previous started task is successfull
taskOK() {
    local -r msg="$1"
    local -r icon="  \e[32m\u2714  "
    local -r clr="\e[0m"
    [[ ! -v DEBUG ]] && { _taskCursorStart; printf "\033[F\r\033[K"; }
    printf "${icon}${msg}${clr}\n"
    [[ ! -v DEBUG ]] && { _taskCursorEnd; printf "\e[?25h"; }
}

# Log the previous started task is failed
taskFail() {
    local -r msg="$1"
    local -r icon="  \e[31m\u2717  "
    local -r clr="\e[0m"
    [[ ! -v DEBUG ]] && { _taskCursorStart; printf "\033[F\r\033[K"; }
    printf "${icon}${msg}${clr}\n"
    [[ ! -v DEBUG ]] && { _taskCursorEnd; printf "\e[?25h"; }
}

# Log extra information on the task
taskInfo() {
    [[ ! -v VERBOSE && ! -v DEBUG ]] && return
    local -r msg="$1"
    local -r icon="     "
    local -r clr="\e[0m"
    INFOLINESCOUNT=$((INFOLINESCOUNT + 1))
    printf "${icon}- ${msg}${clr}\n"
}

# Move the cursor to the start of the current action
_taskCursorStart() {
    for n in $(seq 1 "$INFOLINESCOUNT")
    do
        printf "\033[F"
    done
}

# Move the cursor to the end of stdout
_taskCursorEnd() {
    for n in $(seq 1 "$INFOLINESCOUNT")
    do
        printf "\033[B"
    done
}

# Log an error and exit the script with the provided error code
die() {
    local -r msg="$1"
    local -r err="${2:1}"
    logError "$msg"
    exit $err
}

# Log an error but allow to continue the script
logError() {
    local -r msg="$1"
    printf "\e[1;31mERROR: ${msg}\e[0m\n"
}

# Log a warning message with the provided message
logWarn() {
    local -r msg="$1"
    printf "\e[1;33mWARN: ${msg}\e[0m\n"
}

# Log a regular message (For Verbose/Debug Mode)
log() {
    [[ ! -v VERBOSE && ! -v DEBUG ]] && return
    local -r msg="$1"
    printf "INFO: ${msg}\e[0m\n"
}

# Run a command in verbose or quiet mode
run() {
    local -r command="$@"

    if [[ -v DEBUG ]]; then
        ${command}
        local -r ret="$?"
    else
        ${command} > /dev/null 2>&1
        local -r ret="$?"
    fi
    return $ret
}

# Function to display usage
usage() {
    cat <<EOF
$SCRIPT_TAG_LINE

Usage: $SCRIPT_NAME [OPTIONS] ...

Options:
  -d, --debug         Enable debug and verbose output.
  -v, --verbose       Enable verbose output.

  -h, --help          Show this help message and exit.
EOF
    exit "$1"
}

# Function to parse the arguments of the script
parseArguments() {
    # Use getopt to parse the options
    OPTS=$(getopt -o dvh --long debug,verbose,help -n "$SCRIPT_NAME" -- "$@")

    [[ $? -ne 0 ]] && usage 22

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -d|--debug)
            log "Parameter \e[36m${1}\e[0m detected"
            DEBUG=1
            shift
            ;;
            -v|--verbose)
            log "Parameter \e[36m${1}\e[0m detected"
            VERBOSE=1
            shift
            ;;
            -h|--help)
            usage 0
            return 0
            ;;
            --)
            shift
            break
            ;;
            *)
            # Should not happen (getopt should catch invalid options)
            die "Internal error in argument parsing!" 22
            ;;
        esac
    done
}


readonly TRUE=0
readonly FALSE=1

# Check if the script is run as root
isRoot() {
    [[ $EUID -eq 0 ]] && return $TRUE || return $FALSE
}

# Check if the script is run through sudo
isSudo() {
    [[ -v SUDO_USER ]] && return $TRUE || return $FALSE
}

# Check if the distrbution is Debian
isDebian() {
    [[ -f /etc/debian_version ]] && return $TRUE || return $FALSE
}

# Check if an application is installed
# Example usage: isInstalled "apt-get"
isInstalled() {
    if command -v "$1" &> /dev/null; then
        return $TRUE
    fi
    return $FALSE
}


# Task to perform a full distribution upgrade
taskDistUpgrade() {
    taskStart "Upgrading the distribution"

    taskInfo "Updating the cache"
    run "${SUDO}apt-get update" || { taskFail "Upgrade Failed!"; return 1; }
    updateSudo
    taskInfo "Updating the installed applications"
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::="--force-confnew" \
        -o DPkg::Options::="--force-confdef" \
        upgrade" || { taskFail "Upgrade Failed!"; return 1; }
    updateSudo
    taskInfo "Performing a full distribution upgrade"
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::="--force-confold" \
        -o DPkg::Options::="--force-confdef" \
        dist-upgrade" || { taskFail "Upgrade Failed!"; return 1; }
    updateSudo
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get clean" && taskInfo "Cleaning the system" || taskInfo "Couldn't cleanup the system"
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge" && taskInfo "Removing unused dependencies" || taskInfo "Couldn't remove unused dependencies"
    updateSudo
    taskOK "Distribution fully upgraded"
    return 0
}

# Task to update the system
taskUpdate() {
    taskStart "Updating the system"

    taskInfo "Updating the cache"
    run "${SUDO}apt-get update"  || { taskFail "Upgrade Failed!"; return 1; }
    updateSudo

    taskInfo "Updating the installed applications"
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::="--force-confnew" \
        -o DPkg::Options::="--force-confdef" \
        upgrade" || { taskFail "Upgrade Failed!"; return 1; }
    updateSudo
    taskOK "System updated"
    return 0
}

# Task to clean the system
taskClean() {
    taskStart "Cleaning the system"

    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get clean" && taskInfo "Cleaning the system" || taskInfo "Couldn't cleanup the system"
    run "${SUDO}DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge" && taskInfo "Removing unused dependencies" || taskInfo "Couldn't remove unused dependencies"
    updateSudo
    taskOK "System cleaned"
}



# Ask the user to reboot the system
askReboot() {
    echo -e "\n\nYou need to \e[36mreboot\e[0m the system."

    while true; do
        read -p "Do you want to reboot the system? (Y/n): " response
        case "$response" in
            [Nn][Oo]|[Nn])
            logWarn "Make sure to reboot the system for the changes to take effects!"
            break
            ;;
            [Yy][Ee][Ss]|[Yy]|'')
            log "Rebooting system after cleanup"
            cleanup
            ${SUDO}shutdown -r now
            break
            ;;
            *)
            logError "Invalid input. Please enter Y, y, yes, n, no, or leave empty."
            updateSudo
            ;;
        esac
    done
}

# Update the sudo timestamp so it does not ask for the passwork again
updateSudo() {
    [[ -n "$SUDO" ]] && ${SUDO}-v
}


# Task to setup the Debian testing repositories
taskTestingRepos() {
    taskStart "Setting up Debian Testing"

    local name=$(getTestingName)
    taskInfo "The testing release name is \e[36m${name}\e[0m"

    cleanupSourceslist
    setupRepositorySource "$name" || { taskFail "Couldn't setup the repositories"; return 1; }

    taskOK "Debian Testing Setup"
    return 0
}

# Get the name of the testing release from the debian website (or use testing)
getTestingName() {
    local -r debianTestingURL="https://www.debian.org/releases/testing/"
    local testingName="testing"
    local -r output=$(wget -q -O - "$debianTestingURL" | grep '<h1>Debian &ldquo;.*&rdquo; Release Information</h1>')
    if [[ $output ]]; then
        testingName=$(echo "$output" | grep -om1 '&ldquo;.*&rdquo;' | sed 's/&ldquo;\|&rdquo;\|//g')
    fi
    echo "${testingName}"
}

# Backing up and removing old style sources.list file
cleanupSourceslist() {
    local -r file="/etc/apt/sources.list"
    [[ -f "${file}" ]] || { taskInfo "No files at \e[36m${file}\e[0m"; return; }
    taskInfo "Renaming \e[36m${file}\e[0m to \e[36m${file}.bak\e[0m"
    ${SUDO}mv -f "${file}" "${file}.bak"
    updateSudo
}

# Write the 00_Debian.sources file as a Deb822 format.
setupRepositorySource() {
    local -r name="$1"
    local -r tmpfile="$TMPFOLDER/Debian.sources"
    local -r file="/etc/apt/sources.list.d/Debian.sources"
    taskInfo "Setting up \e[36m${name}\e[0m using Deb822 format"
    ${SUDO}cat <<EOF >"${tmpfile}"
Types: deb
URIs: https://deb.debian.org/debian
Suites: ${name} ${name}-updates
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security
Suites: ${name}-security
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    if [[ -f "${file}" ]]; then
        taskInfo "Making a backup of \e[36m${file}\e[0m"
        ${SUDO}cp -f "${file}" "${file}.bak"
    else
        taskInfo "Creating file \e[36m${file}\e[0m"
        ${SUDO}touch "${file}"
    fi  || { taskInfo "Source file \e[36m${file}\e[0m! does not exist!"; return 1; }
    ${SUDO}cp -f "${tmpfile}" "${file}"
    updateSudo
    return 0
}

# Task to create a temporary folder
taskCreateTempFolder() {
    taskStart "Creating temp folder"
    TMPFOLDER=$(mktemp -d -q "/tmp/setup-XXX")
    [[ $? ]] || { taskFail "Couldn't create temporary folder"; return 1; }
    taskInfo "Temporary folder \e[36m$TMPFOLDER\e[0m"
    taskOK "Temporary folder created"
    return 0
}

# Delete the temporary folder if not in debug
cleanTempFolder() {
    [[ -v DEBUG || ! -v TMPFOLDER ]] && return
    log "Cleaning up temporary folder \e[36m$TMPFOLDER\e[0m"
    rm -Rf $TMPFOLDER
}

# Constants
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_TAG_LINE="Setup Debian testing repositories"

# Cleanup Function
cleanup() {
    cleanTempFolder
}

# Checklist for the script
checklist() {
    if ! isDebian; then die "The script should be run on a Debian system!" 1; fi
    log "Debian system detected"

    if isRoot; then log "Script run as \e[36mroot\e[0m user"; SUDO="";  fi
    if isSudo; then log "Script run as \e[36m$USER\e[0m using \e[36msudo\e[0m"; SUDO=""; fi
    if [[ ! -v SUDO ]]; then
        log "Script run as \e[36m$USER\e[0m without \e[36msudo\e[0m priviledges"
        if ! isInstalled "sudo"; then die "sudo is not installed on the system!"; fi
        log "\e[36msudo\e[0m is installed on the system"
        SUDO="sudo "
        echo -e "Some command will require \e[36msudo\e[0m priviledges"
        updateSudo
    fi
}

# Clear the sreen and print the header for the script
printHeader() {
    [[ ! -v DEBUG ]] && clear
    printf "\n"
    printf "______     _     _               _____        _   _             \n"
    printf "|  _  \   | |   (_)             |_   _|      | | (_)            \n"
    printf "| | | |___| |__  _  __ _ _ __     | | ___ ___| |_ _ _ __   __ _ \n"
    printf "| | | / _ | '_ \| |/ _` | '_ \    | |/ _ / __| __| | '_ \ / _` |\n"
    printf "| |/ |  __| |_) | | (_| | | | |   | |  __\__ | |_| | | | | (_| |\n"
    printf "|___/ \___|_.__/|_|\__,_|_| |_|   \_/\___|___/\__|_|_| |_|\__, |\n"
    printf "                                                           __/ |\n"
    printf "                                                          |___/ \n"
    printf "\n"
    printf "\e[1m${SCRIPT_TAG_LINE}\e[0m\n"
    printf "\n"
}

# Initialize
parseArguments $@
printHeader
checklist

# Tasks
printHeader
taskCreateTempFolder || die "Couldn't create temporary folder!" 1
taskTestingRepos || die "Couldn't setup the testing repositories!" 95
taskDistUpgrade || die "Couldn't perform a distribution upgrade!" 95

askReboot
exit 0
