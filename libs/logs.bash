## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##             Logging Functions             ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

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
