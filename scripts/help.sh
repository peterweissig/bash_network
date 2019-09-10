#!/bin/bash

#***************************[help]********************************************
# 2019 09 10

function network_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME  #no help"
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
