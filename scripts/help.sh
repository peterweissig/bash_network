#!/bin/bash

#***************************[help]********************************************
# 2018 09 03
function network_help() {

    echo ""
    echo "### network_help ###"
    echo ""
    echo "file transfer"
    echo -n "  "; network_send_files -h
    echo -n "  "; network_receive_files -h
    echo ""
    echo "general commands"
    echo -n "  "; network_ping -h
    echo -n "  "; network_ssh -h
    echo ""
}
