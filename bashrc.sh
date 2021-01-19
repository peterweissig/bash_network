#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_NETWORK" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_NETWORK="$SOURCED_BASH_LAST"



#***************************[optional external variables]*********************
# 2020 04 07

# NETWORK_PATH_LOG
if [ "$NETWORK_PATH_LOG" != "" ] && [ ! -d "$NETWORK_PATH_LOG" ]; then
    echo -n "Error sourcing \"network\": "
    echo "path \$NETWORK_PATH_LOG does not exist"
fi



#***************************[paths and files]*********************************
# 2021 01 06

export NETWORK_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

if [ "$NETWORK_PATH_LOG" == "" ]; then
    # check if an alternative path exists
    if [ "$REPO_BASH_DATA_PATH" != "" ] && \
      [ -d "$REPO_BASH_DATA_PATH" ]; then
        export NETWORK_PATH_LOG="${REPO_BASH_DATA_PATH}network/"
    else
        export NETWORK_PATH_LOG="${NETWORK_PATH}log/"
    fi

    # check if log folder exists
    if [ ! -d "$NETWORK_PATH_LOG" ]; then
        echo "creating log folder for \"network\""
        echo "    ($NETWORK_PATH_LOG)"
        mkdir -p "$NETWORK_PATH_LOG"
    fi
fi



#***************************[source]******************************************
# 2021 01 19

. ${NETWORK_PATH}scripts/files.sh
. ${NETWORK_PATH}scripts/ssh.sh
. ${NETWORK_PATH}scripts/ping.sh
. ${NETWORK_PATH}scripts/help.sh
