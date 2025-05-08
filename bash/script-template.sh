#!/usr/bin/env bash

# set -x      # echo the executing cmd, usefull for debugging

# ------------------ add the library functions below ------------------------
fn_cmdCheck() {
    local cmd2check=$1
    if [[ -z "$1" ]]; then
        echo "Missing args for function <fn_cmdCheck(<cmd>)>."
        return 1
    fi
    set -e
    local cmdPath=$(command -v $1)
    set +e
    if [[ -z "${cmdPath}" ]]; then
        echo "Missing Command <$cmd2check>, please install it first."
        return 2
    else
        echo "Found command <$cmd2check> at <$cmdPath>, continue..."
        return 0
    fi
}

fn_joinFiles() {
    local targetFile=$1
    local appendFiles=${@:2}  # via: https://stackoverflow.com/questions/3811345/how-to-pass-all-arguments-passed-to-my-bash-script-to-a-function-of-mine
    # do file join actions
    echo "" > $targetFile    # create the empty target file
    for f in $appendFiles
    do
        cat "$f" >> $targetFile   # append the joining file to the target file.
    done
}
# ------------------ end of the library functions ---------------------------


# --------------- modify the essential functions below ----------------------
fn_help () {
    # TODO: modify the help text below
    echo "<$0> help-text-to-be-added"
}

fn_clean() {
    :; # TODO: append the clean actions below
}

MAIN_ESSENTIAL_ARGS_LEN=2
fn_main() {
    # TODO: write the main actions below
    # ---- below is the example -------
    # essential function for this script.
    fn_cmdCheck cat
    fn_cmdCheck abc
    abc
    # fn_cmdCheck abc     # this command must be failed.
    # fn_joinFiles $@
    echo "sleeping..."
    sleep 10
}
# ------------------ end of the essential functions -------------------------


# ------- based functions are below -----------------
# Do NOT modify the below codes unless you know why.
# ---------------------------------------------------
_help() {
    # call fn_help function to print help info
    fn_help
}

_clean() {
    # clean the script executing data
    echo "Cleaning..."
    fn_clean
    echo "Cleaned."
}

_error() {
    # handle error raised during the script is executing.
    echo "From lineno: $1 exiting with code $2 (last command was: $3)"
    _clean
    exit "$2"
}

_handle() {
    # handle signal raised during the script is executing.
    echo ""
    echo "Catch signal <$1>"
    _clean
}

_main () {
    # the main function struct
    # 1. check the args number length and print
    if [[ $# -ne "$MAIN_ESSENTIAL_ARGS_LEN" ]]; then
        _help
        echo "Script exit 1"
        exit 1
    else
        echo "Script <$0> is running with the following args:"
        for i in "${@}"; do
            # NOTICE: This solution requires all args cannot has any spaces
            echo "    <$i>"
        done
    fi
    # 2. bind the trap functions
    # 1     SIGHUP
    # 2     SIGINT
    # 3     SIGQUIT
    # 6     SIGABRT
    # 9     SIGKILL
    # 15    SIGTERM
    # for sig in 1 2 3 6 9 15
    # do
    #     trap "_handle $sig" $sig
    # done
    trap '"_error" "$LINENO" "$?"  "$BASH_COMMAND"' ERR
        # via:  https://stackoverflow.com/questions/56055668/how-to-get-return-code-in-trap-return
    # 3. execute the <fn_main> function which defined by user
    set -e -o pipefail
        # This script will be exited at command error raising or pipeline failed.
    fn_main $@
    local ret=$?
    # 4. clean the environment and exit the script
    if [[ $ret -eq 0 ]]; then
        echo "Script finished."
        _clean
    else
        # skip the other return code since the "set -e" command settings
        #:;
        echo "Script failed."
    fi
    exit $ret
}

_main $@
