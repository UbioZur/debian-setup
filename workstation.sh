#!/usr/bin/env bash
# ##  ~ UbioZur - https://github.com/UbioZur ~  ##

# Setup and bootstrap my minimal debian install
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
source ./tasks/cliapps.bash
source ./tasks/consolefont.bash
source ./tasks/dotfiles.bash
source ./tasks/grub.bash
source ./tasks/system.bash
source ./tasks/tmpfolder.bash

# Constants
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_TAG_LINE="Setup Personal Debian Workstation System"

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
## https://patorjk.com/software/taag/#p=display&h=0&v=1&f=Graffiti&t=Headless
printHeader() {
    [[ ! -v DEBUG ]] && clear
    printf "\n"
    printf " _    _            _        _        _   _             \n"
    printf "| |  | |          | |      | |      | | (_)            \n"
    printf "| |  | | ___  _ __| | _____| |_ __ _| |_ _  ___  _ __  \n"
    printf "| |/\| |/ _ \| '__| |/ / __| __/ _' | __| |/ _ \| '_ \ \n"
    printf "\  /\  | (_) | |  |   <\__ | || (_| | |_| | (_) | | | |\n"
    printf " \/  \/ \___/|_|  |_|\_|___/\__\__,_|\__|_|\___/|_| |_|\n"
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
taskUpdate || logWarn "System update did not happen, Setup may not work as expected!"
taskSetupGrub || logWarn "Grub Setup did not happen, System may not work as expected!"
taskCLIApps || logWarn "Applications not installed, Setup may not work as expected!"
taskAllDotfiles || logWarn "Dotfiles not installed, System may not work as expected!"
taskSetupConsoleFont || logWarn "Console font not configure, System may not work as expected!"
taskClean || logWarn "System cleaning failed, Try to run sudo apt clean && sudo apt autoremove --purge"

askReboot
exit 0
