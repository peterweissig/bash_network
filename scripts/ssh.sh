#!/bin/bash

#***************************[ssh]*********************************************
# 2018 09 03

function network_ssh() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <computers> [<user>] [<command>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: list of computers (space separated)"
        echo "    [#2:]remote user name (defaults to current user)"
        echo "    [#3:]script-command to be executed"
        echo "         If command is empty, the script will stay logged in."
        echo "If command is given, executes it on each remote machine."
        echo "Otherwise, logs into each remote machine."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    LIST_OF_COMPUTERS="$1"

    if [ $# -lt 2 ]; then
        REMOTE_USER="$USER"
    else
        REMOTE_USER="$2"
    fi


    # do the main loop for each remote login
    for remote in $LIST_OF_COMPUTERS; do

        REMOTE_LOGIN="${REMOTE_USER}@${remote}"

        if [ "${remote,,}" == "$(hostname)" ]; then

            echo "==========================================================="
            echo "Skipping $REMOTE_LOGIN"
            continue
        fi

        echo ""
        echo "==========================================================="
        echo "ssh $REMOTE_LOGIN"
        echo
        if [ $# -lt 3 ]; then
            ssh "$REMOTE_LOGIN"
        else
            ssh "$REMOTE_LOGIN" bash -c "$3"
        fi
    done
}
