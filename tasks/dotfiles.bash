## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##        Tasks for getting dotfiles         ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##


taskHeadlessDotfiles() {
    local -r dotfileURL="https://github.com/UbioZur/dotfiles.git"
    local -r dotfileFolder="${HOME}/dotfiles"
    taskStart "Setting up Dotfiles"
    if ! isInstalled git; then
        taskFail "Couldn't setup dotfiles (git not found)!"
        return 1
    fi
    if [[ ! -d ${dotfileFolder} ]]; then
        taskInfo "Grabbing the git repo \e[36m$dotfileURL\e[0m"
        run git clone --depth=1 ${dotfileURL} ${dotfileFolder}
    fi
    if [[ ! -d ${dotfileFolder}/.git ]]; then
        taskFail "Couldn't setup dotfiles (Folder exist)!"
        return 1
    fi
    local -r repo=$(git -C ${dotfileFolder} config --get remote.origin.url)
    [[ "${repo}" != "${dotfileURL}" ]] && taskInfo "Dotfile URL \e[36m$dotfileURL\e[0m do not match expected \e[36m$repo\e[0m"
    taskInfo "Pulling git repo \e[36m${repo}\e[0m"
    run git -C ${dotfileFolder} pull
    if [[ ! -f ${dotfileFolder}/makefile ]]; then
        taskFail "Couldn't setup dotfiles (makefile does not exist)!"
        return 1
    fi
    taskInfo "Installing the dotfiles"
    cd ${dotfileFolder}
    run make headless
    taskInfo "Auto update dotfiles"
    run make cron

    taskOK "Headless dotfiles installed"
}

taskAllDotfiles() {
    local -r dotfileURL="git@github.com:ubiozur/dotfiles.git"
    local -r dotfileFolder="${HOME}/github/dotfiles"
    taskStart "Setting up Dotfiles"
    if ! isInstalled git; then
        taskFail "Couldn't setup dotfiles (git not found)!"
        return 1
    fi
    if [[ ! -d ${dotfileFolder} ]]; then
        taskInfo "Grabbing the git repo \e[36m$dotfileURL\e[0m"
        run git clone --depth=1 ${dotfileURL} ${dotfileFolder}
    fi
    if [[ ! -d ${dotfileFolder}/.git ]]; then
        taskFail "Couldn't setup dotfiles (Folder exist)!"
        return 1
    fi
    local -r repo=$(git -C ${dotfileFolder} config --get remote.origin.url)
    [[ "${repo}" != "${dotfileURL}" ]] && taskInfo "Dotfile URL \e[36m$dotfileURL\e[0m do not match expected \e[36m$repo\e[0m"
    taskInfo "Pulling git repo \e[36m${repo}\e[0m"
    run git -C ${dotfileFolder} pull
    if [[ ! -f ${dotfileFolder}/makefile ]]; then
        taskFail "Couldn't setup dotfiles (makefile does not exist)!"
        return 1
    fi
    taskInfo "Installing the dotfiles"
    cd ${dotfileFolder}
    run make all

    taskOK "Workstation dotfiles installed"
}

