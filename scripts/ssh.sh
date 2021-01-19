#!/bin/bash

#***************************[ssh]*********************************************
# 2021 01 19

function network_ssh() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME [--no-passwd] [--interactive] [--expand-aliases]"
        echo " <computers> [<user>] [<command>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 1 option needs 1-3 parameters"
        echo "    [--no-passwd]      no prompt for password at all"
        echo "    [--interactive]    starts an interactive bash session"
        echo "                       (only in effect, if command is set)"
        echo "    [--expand-aliases] expands aliases in the bash session"
        echo "                       (only in effect, if command is set)"
        echo "     #1: list of computers (space separated)"
        echo "    [#2:]remote user name (defaults to current user)"
        echo "    [#3:]script-command to be executed"
        echo "         If command is empty, only the default login shell is"
        echo "         used. Otherwise an additional bash session is invoked,"
        echo "         if --interactive or --expand-aliases are given."
        echo "         Double quotation marks need to be escaped."
        echo "If command is given, executes it on each remote machine."
        echo "Otherwise, logs into each remote machine and waits for user"
        echo "interaction."

        return
    fi

    # check parameter
    # init variables
    option_no_passwd=0
    option_interactive=0
    option_expand_aliases=0
    param_list=""
    param_user=""
    param_cmd=""

    # check and get parameter
    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 6 ]; then
        params_ok=1
        while true; do
            if [ "$1" == "--no-passwd" ]; then
                option_no_passwd=1
                shift
                continue
            elif [ "$1" == "--interactive" ]; then
                option_interactive=1
                shift
                continue
            elif [ "$1" == "--expand-aliases" ]; then
                option_expand_aliases=1
                shift
                continue
            elif [[ "$1" =~ ^-- ]]; then
                echo "$FUNCNAME: Unknown option \"$1\"."
                return -1
            else
                break
            fi
        done
        param_list="$1"
        param_user="$2"
        param_cmd="$3"
        if [ $# -lt 1 ] || [ $# -gt 3 ]; then
            params_ok=0
        fi
    fi
    if [ $params_ok -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    string_no_passwd=""
    if [ $option_no_passwd -ne 0 ]; then
        string_no_passwd="-o PasswordAuthentication=no"
    fi
    string_interactive=""
    if [ $option_interactive -ne 0 ]; then
        string_interactive="-i"
    fi
    string_expand_aliases=""
    if [ $option_expand_aliases -ne 0 ]; then
        string_expand_aliases="-O expand_aliases"
    fi
    if [ "$param_user" == "" ]; then
        param_user="$USER"
    fi


    # do the main loop for each remote login
    for remote in $param_list; do

        REMOTE_LOGIN="${param_user}@${remote}"

        if [ "${remote,,}" == "$(hostname)" ]; then

            echo "==========================================================="
            echo "Skipping $REMOTE_LOGIN"
            continue
        fi

        echo ""
        echo "==========================================================="
        echo "ssh $REMOTE_LOGIN"
        echo
        if [ "$3" == "" ]; then
            ssh $string_no_passwd "$REMOTE_LOGIN"
        else
            if [ "$string_interactive" != "" ] || \
              [ "$string_expand_aliases" != "" ]; then
                ssh $string_no_passwd "$REMOTE_LOGIN" -t \
                  bash $string_expand_aliases $string_interactive -c "\"$3\""
            else
                ssh $string_no_passwd "$REMOTE_LOGIN" "$3"
            fi
        fi
    done
}
