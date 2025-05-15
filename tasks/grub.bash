## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##         Tasks for setting up grub         ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

taskSetupGrub() {
    taskStart "Setting up GRUB boot loader"
    local -r path="/etc/default/grub.d"
    local -r file="${path}/40_custom.cfg"
    local -r tmpfile="${TMPFOLDER}/40_custom.cfg"
    [[ -d ${path} ]] || { taskFail "GRUB does not seem to be used!"; return; }

    taskInfo "Configuring GRUB with file \e[36m$tmpfile\e[0m";
    cat <<EOF >"${tmpfile}"
# Reduce the timeout for faster boot time
GRUB_TIMEOUT=0
GRUB_TIMEOUT_STYLE=hidden
# Make the boot screen a better resolution
GRUB_GFXMODE=1920x1080
EOF
    if [[ -f ${file} ]]; then
        taskInfo "Making a backup of \e[36m$file\e[0m";
        ${SUDO}cp -f "${file}" "${file}.bak"
    fi
    taskInfo "Creating file \e[36m$file\e[0m";
    ${SUDO}cp -f "${tmpfile}" "${file}"

    taskInfo "Updating GRUB"
    run "${SUDO}update-grub" || { taskFail "Failed to Update GRUB!"; return; }
    updateSudo
    taskOK "GRUB is configured"
}
