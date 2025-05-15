## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##              Checks Functions             ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

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
