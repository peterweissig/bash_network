#!/bin/bash

#***************************[transmit files]**********************************
# 2018 09 03

function _network_transmit_files() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <local_path> <computers> <remote_path> <user> "
        echo "<excludes> [<direction>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 5-6 parameters"
        echo "     #1: locale path (e.g. /home/egon/workspace/)"
        echo "     #2: list of computers (e.g. \"bernd torben winfried\")"
        echo "         List is space separated."
        echo "     #3: remote path (e.g. /tmp/data/)"
        echo "     #4: remote user name (e.g. gustav)"
        echo "     #5: exclude-list (e.g. \".* secret vsnfd\")"
        echo "         List is space separated."
        echo "    [#6:]flag for receiving files"
        echo "         If not used , files will be send."
        echo "         If it exists, files will be received."
        echo "Copies files to (or from) the givin remote destinations."

        return
    fi

    # check parameter
    if [ $# -lt 5 ] || [ $# -gt 6 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    LOCAL_PATH="$1"
    LIST_OF_COMPUTERS="$2"
    REMOTE_PATH="$3"
    REMOTE_USER="$4"

    EXCLUDE_LIST="$5"
    EXCLUDE_STR=""

    # create exclude list
    for exclude in $EXCLUDE_LIST; do
        EXCLUDE_STR="${EXCLUDE_STR} --exclude=$(echo "$exclude" | \
          sed "s/^ *'\(.*\)' *$/\1/")"
    done

    # check local path
    if [ $# -lt 6 ] && [ ! -f "$LOCAL_PATH" ] && [ ! -d "$LOCAL_PATH" ]; then
        echo "file/path \"$LOCAL_PATH\" does not exist"
        return -2
    fi

    # do the main loop for each remote login
    for remote in $LIST_OF_COMPUTERS; do

        REMOTE_LOGIN="${REMOTE_USER}@${remote}"
        REMOTE_ADDR="${REMOTE_LOGIN}:${REMOTE_PATH}"

        echo ""
        echo "==========================================================="
        if [ "$LOCAL_PATH" == "$REMOTE_PATH" ] &&
          [ "${remote,,}" == "$(hostname)" ]; then

            echo "Skipping $REMOTE_LOGIN"
            continue
        else
            if [ $# -lt 6 ]; then
                echo "Copying to $REMOTE_LOGIN"
            else
                echo "Copying from $REMOTE_LOGIN"
            fi
            echo ""
        fi

        if [ $# -lt 6 ]; then
            rsync -az -v "$LOCAL_PATH" "$REMOTE_ADDR" $EXCLUDE_STR
        else
            LOCAL_PATH_TEMP="${LOCAL_PATH}${remote}/"
            mkdir -p "$LOCAL_PATH_TEMP"

            echo "rsync -az -v \"$REMOTE_ADDR\" \"$LOCAL_PATH_TEMP\" \\"
            echo "  ${EXCLUDE_STR} --prune-empty-dirs"
            rsync -az -v "$REMOTE_ADDR" "$LOCAL_PATH_TEMP" ${EXCLUDE_STR} \
              --prune-empty-dirs
        fi
    done
}

# 2018 09 03
function network_send_files() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <local_path> <computers> [<remote_path>] [<user>] "
        echo "[<excludes>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2-5 parameters"
        echo "     #1: locale path (e.g. /home/egon/workspace/)"
        echo "     #2: list of computers (e.g. \"bernd torben winfried\")"
        echo "         List is space separated."
        echo "    [#3:]remote path (defaults to the local path)"
        echo "    [#4:]remote user name (defaults to current user)"
        echo "    [#5:]exclude-list (e.g. \".* secret vsnfd\")"
        echo "         List is space separated."
        echo "Copies files to the givin remote destinations."

        return
    fi

    # check parameter
    if [ $# -lt 2 ] || [ $# -gt 5 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    LOCAL_PATH="$1"

    LIST_OF_COMPUTERS="$2"

    if [ $# -lt 3 ]; then
        REMOTE_PATH="$1"
    else
        REMOTE_PATH="$3"
    fi

    if [ $# -lt 4 ]; then
        REMOTE_USER="$USER"
    else
        REMOTE_USER="$4"
    fi

    if [ $# -lt 5 ]; then
        EXCLUDE_LIST=""
    else
        EXCLUDE_LIST="$5"
    fi

    # call subfunction
    _network_transmit_files "$LOCAL_PATH" "$LIST_OF_COMPUTERS" \
      "$REMOTE_PATH" "$REMOTE_USER" "$EXCLUDE_LIST"
}

# 2018 09 03
function network_receive_files() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <local_path> <computers> [<remote_path>] [<user>] "
        echo "[<excludes>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2-5 parameters"
        echo "     #1: locale path (e.g. /home/egon/workspace/)"
        echo "     #2: list of computers (e.g. \"bernd torben winfried\")"
        echo "         List is space separated."
        echo "    [#3:]remote path (defaults to the local path)"
        echo "    [#4:]remote user name (defaults to current user)"
        echo "    [#5:]exclude-list (e.g. \".* secret vsnfd\")"
        echo "         List is space separated."
        echo "Copies files from the givin remote destinations."

        return
    fi

    # check parameter
    if [ $# -lt 2 ] || [ $# -gt 5 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    LOCAL_PATH="$1"

    LIST_OF_COMPUTERS="$2"

    if [ $# -lt 3 ]; then
        REMOTE_PATH="$1"
    else
        REMOTE_PATH="$3"
    fi

    if [ $# -lt 4 ]; then
        REMOTE_USER="$USER"
    else
        REMOTE_USER="$4"
    fi

    if [ $# -lt 5 ]; then
        EXCLUDE_LIST=""
    else
        EXCLUDE_LIST="$5"
    fi

    # call subfunction
    _network_transmit_files "$LOCAL_PATH" "$LIST_OF_COMPUTERS" \
      "$REMOTE_PATH" "$REMOTE_USER" "$EXCLUDE_LIST" "flag_for_receiving"
}
