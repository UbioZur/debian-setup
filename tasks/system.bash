## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##      Tasks for updating the system        ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

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
