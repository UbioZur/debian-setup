#!/usr/bin/env bash
##  ~ UbioZur - https://github.com/UbioZur ~  ##

# Setup Debian Testing Repositories
# License: MIT | https://github.com/UbioZur/debian-setup/raw/main/LICENSE

# Fail Fast and cleanup
set -Eeuo pipefail
# trap cleanup SIGINT SIGTERM ERR EXIT
trap cleanup EXIT

## Source the required libraries
source ./libs/logs.bash
source ./libs/commands.bash
source ./libs/params.bash
source ./libs/checks.bash

## Sources tasks
source ./tasks/system.bash
source ./tasks/testing.bash
source ./tasks/tmpfolder.bash

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
## https://patorjk.com/software/taag/#p=display&h=3&v=0&f=Doom&t=Debian%20Testing
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
