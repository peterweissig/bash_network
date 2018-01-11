#***************************[transmit files]**********************************
# 2017 06 08

function _network_transmit_files() {

    if [ $# -lt 5 ] || [ $# -gt 6 ]; then
        echo "Error - _network_transmit_files needs 5-6 parameters"
        echo "        #1: locale path"
        echo "        #2: list of computers (space separated)"
        echo "        #3: remote path"
        echo "        #4: user name"
        echo "        #5: exclude-List"
        echo "       [#6:]if exists - files will be received and not send"

        return
    fi

    LOCAL_PATH="$1"
    LIST_OF_COMPUTERS="$2"
    REMOTE_PATH="$3"
    REMOTE_USER="$4"

    EXCLUDE_LIST="$5"
    EXCLUDE_STR=""
    for exclude in $EXCLUDE_LIST; do
        EXCLUDE_STR="${EXCLUDE_STR} --exclude=$(echo "$exclude" | \
          sed "s/^ *'\(.*\)' *$/\1/")"
    done


    if [ $# -lt 6 ] && [ ! -f "$LOCAL_PATH" ] && [ ! -d "$LOCAL_PATH" ]; then
        echo "file/path \"$LOCAL_PATH\" does not exist"
        return
    fi

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

function _network_send_files() {

    if [ $# -lt 2 ] || [ $# -gt 5 ]; then
        echo "Error - _network_send_files needs 2-5 parameters"
        echo "        #1: locale path"
        echo "        #2: list of computers (space separated)"
        echo "       [#3]: remote path"
        echo "       [#4]: user name"
        echo "       [#5]: exclude-List"

        return
    fi

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

    _network_transmit_files "$LOCAL_PATH" "$LIST_OF_COMPUTERS" \
      "$REMOTE_PATH" "$REMOTE_USER" "$EXCLUDE_LIST"
}


function _network_receive_files() {

    if [ $# -lt 2 ] || [ $# -gt 5 ]; then
        echo "Error - _network_receive_files needs 2-5 parameters"
        echo "        #1: locale path"
        echo "        #2: list of computers (space separated)"
        echo "       [#3]: remote path"
        echo "       [#4]: user name"
        echo "       [#5]: exclude-List"

        return
    fi

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

    _network_transmit_files "$LOCAL_PATH" "$LIST_OF_COMPUTERS" \
      "$REMOTE_PATH" "$REMOTE_USER" "$EXCLUDE_LIST" "dummy_for_receiving"
}


#***************************[ssh]*********************************************
# 2017 06 08

function _network_ssh() {

    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "Error - _network_ssh needs 1-3 parameters"
        echo "        #1: list of computers (space separated)"
        echo "       [#2]: user name"
        echo "       [#3]: script-command to be executed"

        return
    fi

    LIST_OF_COMPUTERS="$1"

    if [ $# -lt 2 ]; then
        REMOTE_USER="$USER"
    else
        REMOTE_USER="$2"
    fi


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


#***************************[ping]********************************************
# 2018 01 11

function _network_ping() {

    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
        echo "Error - _network_ping needs 1 parameter"
        echo "        #1: host as IP-Adress or name"

        return
    fi

    ping -q -c 1 -i 0.2 -w 1 "$1"
}
