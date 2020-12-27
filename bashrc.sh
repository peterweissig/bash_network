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
# 2020 12 27

export NETWORK_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

if [ "$NETWORK_PATH_LOG" == "" ]; then
    export NETWORK_PATH_LOG="${NETWORK_PATH}log/"
fi


#***************************[source]******************************************
# 2020 04 07

. ${NETWORK_PATH}scripts/functions.sh
. ${NETWORK_PATH}scripts/help.sh
