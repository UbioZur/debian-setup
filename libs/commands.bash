## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##            commands Functions             ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

# Run a command in verbose or quiet mode
run() {
    local -r command="$@"

    if [[ -v DEBUG ]]; then
        ${command}
        local -r ret="$?"
    else
        ${command} > /dev/null 2>&1
        local -r ret="$?"
    fi
    return $ret
}
