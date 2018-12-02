#!/bin/bash

#***************************[check if already sourced]************************
# 2018 11 30

if [ "$SOURCED_BASH_NETWORK" != "" ]; then

    return
    exit
fi

export SOURCED_BASH_NETWORK=1


#***************************[paths and files]*********************************
# 2018 11 17

temp_local_path="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"


#***************************[source]******************************************
# 2018 04 01

. ${temp_local_path}scripts/functions.sh
. ${temp_local_path}scripts/help.sh
