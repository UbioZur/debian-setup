## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##        Tasks for Temporary folder         ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

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
