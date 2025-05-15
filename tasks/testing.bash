## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##     Tasks for Testing Repositories        ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##


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
