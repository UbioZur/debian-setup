## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##           Tasks for console font          ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

taskSetupConsoleFont() {
    taskStart "Configuring TTY font"
    local -r file="/etc/default/console-setup"
    local -r tmpfile="${TMPFOLDER}/console-setup"

    taskInfo "Configuring TTY font with file \e[36m$tmpfile\e[0m";
    cat <<EOF >"${tmpfile}"
# CONFIGURATION FILE FOR SETUPCON
# Consult the console-setup(5) manual page.
ACTIVE_CONSOLES="/dev/tty[1-6]"
CHARMAP="UTF-8"
CODESET="Lat15"
FONTFACE="Terminus"
FONTSIZE="10x20"
VIDEOMODE=

EOF
    if [[ -f ${file} ]]; then
        taskInfo "Making a backup of \e[36m$file\e[0m";
        ${SUDO}cp -f "${file}" "${file}.bak"
    fi
    taskInfo "Creating file \e[36m$file\e[0m";
    ${SUDO}cp -f "${tmpfile}" "${file}"
    taskInfo "Updating initramfs"
    run "${SUDO}update-initramfs -u" || { taskFail "Failed to Update initramfs!"; return 1; }
    updateSudo
    taskOK "Console font configured"
}
