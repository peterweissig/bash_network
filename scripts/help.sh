#!/bin/bash

#***************************[help]********************************************
# 2020 04 07

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
    echo "log network delay"
    echo -n "  "; network_log_ping -h
    echo -n "  "; network_log_list -h
    echo -n "  "; network_log_plot -h
    echo ""
}
