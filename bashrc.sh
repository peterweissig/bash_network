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
# 2021 03 21

export NETWORK_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

# load and check data dir
if [ "$NETWORK_PATH_LOG" == "" ]; then
    NETWORK_PATH_LOG="$(_repo_bash_data_dirs_get --mkdir "network" \
      "${NETWORK_PATH}log/")"
fi
if type -t _repo_bash_data_dirs_check >> /dev/null; then
    _repo_bash_data_dirs_check --rmdir "$NETWORK_PATH_LOG" \
      "network" "${NETWORK_PATH}log/"
fi



#***************************[source]******************************************
# 2021 03 24

source "${NETWORK_PATH}scripts/files.sh"
source "${NETWORK_PATH}scripts/ssh.sh"
source "${NETWORK_PATH}scripts/ping.sh"
source "${NETWORK_PATH}scripts/help.sh"
