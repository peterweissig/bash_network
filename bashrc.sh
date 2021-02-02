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
# 2021 02 02

export NETWORK_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

# load and check data dir
if [ "$NETWORK_PATH_LOG" == "" ]; then
    NETWORK_PATH_LOG="$(_repo_bash_data_dirs_get --mkdir "network" \
      "${NETWORK_PATH}log/")"
fi
_repo_bash_data_dirs_check --rmdir "$NETWORK_PATH_LOG" \
  "network" "${NETWORK_PATH}log/"



#***************************[source]******************************************
# 2021 01 19

. ${NETWORK_PATH}scripts/files.sh
. ${NETWORK_PATH}scripts/ssh.sh
. ${NETWORK_PATH}scripts/ping.sh
. ${NETWORK_PATH}scripts/help.sh
