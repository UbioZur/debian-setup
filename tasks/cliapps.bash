## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##         Tasks for installing apps         ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

# Install a bunch of CLI Apps
taskCLIApps() {
    taskStart "Installing CLI applications"

    local -r apps="7zip 7zip-rar anacron aptitude bash bash-completion bat ca-certificates checksecurity cron curl debian-archive-keyring eza fastfetch fd-find git gnupg less logrotate make make-doc micro powertop ripgrep rsync trash-cli udisks2 unzip wget zoxide"

    taskInfo "Updating the cache"
    run "${SUDO}apt-get install -y ${apps}" || { taskFail "Install Failed!"; return 1; }
    updateSudo

    taskOK "CLI applications installed"
}

## 7zip https://packages.debian.org/search?searchon=names&keywords=7zip file archiver with a high compression ratio
## 7zip-rar https://packages.debian.org/search?searchon=names&keywords=7zip-rar RAR codec module for 7zip
## anacron https://packages.debian.org/search?searchon=names&keywords=anacron cron with @daily @hourly etc
## aptitude https://packages.debian.org/search?searchon=names&keywords=aptitude terminal-based package manager (prefered by ansible)
## bash https://packages.debian.org/search?searchon=names&keywords=bash GNU Bourne Again SHell
## bash-completion https://packages.debian.org/search?searchon=names&keywords=bash-completion programmable completion for the bash shell
## bat https://packages.debian.org/search?searchon=names&keywords=bat cat clone with syntax highlighting and git integration
## ca-certificates https://packages.debian.org/search?searchon=names&keywords=ca-certificates Common CA certificates
## checksecurity https://packages.debian.org/search?searchon=names&keywords=checksecurity basic system security checks
## cron https://packages.debian.org/search?searchon=names&keywords=cron process scheduling daemon
## curl https://packages.debian.org/search?searchon=names&keywords=curl command line tool for transferring data with URL syntax
## debian-archive-keyring https://packages.debian.org/search?searchon=names&keywords=debian-archive-keyring GnuPG archive keys of the Debian archive
## eza https://packages.debian.org/search?searchon=names&keywords=eza Modern replacement for ls
## fastfetch https://packages.debian.org/search?searchon=names&keywords=fastfetch neofetch-like tool for fetching system information
## fd-find https://packages.debian.org/search?searchon=names&keywords=fd-find Simple, fast and user-friendly alternative to find
## git https://packages.debian.org/search?searchon=names&keywords=git fast, scalable, distributed revision control system
## gnupg https://packages.debian.org/search?searchon=names&keywords=gnupg GNU privacy guard - a free PGP replacement
## less https://packages.debian.org/search?searchon=names&keywords=less pager program similar to more
## logrotate https://packages.debian.org/search?searchon=names&keywords=logrotate Log rotation utility
## make https://packages.debian.org/search?searchon=names&keywords=make utility for directing compilation
## make-doc https://packages.debian.org/search?searchon=names&keywords=make-doc Documentation for the GNU version of the "make" utility
## micro https://packages.debian.org/search?searchon=names&keywords=micro modern and intuitive terminal-based text editor
## powertop https://packages.debian.org/search?searchon=names&keywords=powertop diagnose issues with power consumption and management
## ripgrep https://packages.debian.org/search?searchon=names&keywords=ripgrep Recursively searches directories for a regex pattern
## rsync https://packages.debian.org/search?searchon=names&keywords=rsync fast, versatile, remote (and local) file-copying tool
## trash-cli https://packages.debian.org/search?searchon=names&keywords=trash-cli command line trashcan utility
## udisks2 https://packages.debian.org/search?searchon=names&keywords=udisks2 D-Bus service to access and manipulate storage devices
## unzip https://packages.debian.org/search?searchon=names&keywords=unzip De-archiver for .zip files
## wget https://packages.debian.org/search?searchon=names&keywords=wget retrieves files from the web
## zoxide https://packages.debian.org/search?searchon=names&keywords=zoxide Faster way to navigate your filesystem
