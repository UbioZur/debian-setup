## ##### ##### ##### ##### ##### ##### ##### ##
##                                           ##
##           Parameters Functions            ##
##                                           ##
## ##### ##### ##### ##### ##### ##### ##### ##

# Function to display usage
usage() {
    cat <<EOF
$SCRIPT_TAG_LINE

Usage: $SCRIPT_NAME [OPTIONS] ...

Options:
  -d, --debug         Enable debug and verbose output.
  -v, --verbose       Enable verbose output.

  -h, --help          Show this help message and exit.
EOF
    exit "$1"
}

# Function to parse the arguments of the script
parseArguments() {
    # Use getopt to parse the options
    OPTS=$(getopt -o dvh --long debug,verbose,help -n "$SCRIPT_NAME" -- "$@")

    [[ $? -ne 0 ]] && usage 22

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -d|--debug)
            log "Parameter \e[36m${1}\e[0m detected"
            DEBUG=1
            shift
            ;;
            -v|--verbose)
            log "Parameter \e[36m${1}\e[0m detected"
            VERBOSE=1
            shift
            ;;
            -h|--help)
            usage 0
            return 0
            ;;
            --)
            shift
            break
            ;;
            *)
            # Should not happen (getopt should catch invalid options)
            die "Internal error in argument parsing!" 22
            ;;
        esac
    done
}

