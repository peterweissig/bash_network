#!/bin/bash

#***************************[ping]********************************************
# 2021 01 05

function network_ping() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <destination>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameters"
        echo "     #1: destination address (e.g. 192.168.1.123)"
        echo "         May also be given as a hostname (e.g. egon.local)."
        echo "Pings the given host up to 5 times within one second."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # ping the host
    LC_ALL=C.UTF-8 ping -q -c 1 -i 0.2 -w 1 "$1"
}

# 2021 03 21
function network_log_ping() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <destination> [<gateway>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: destination address (e.g. 192.168.1.123)"
        echo "         May also be given as a hostname (e.g. egon.local)."
        echo "    [#2:]gateway address (e.g. 192.168.2.1)"
        echo "         If the gateway is given, it is pinged first."
        echo "Pings the given host up to 5 times within 10 seconds."
        echo "The average ping-time will be logged to file."
        echo ""
        echo "The logging can be done via crontab(e.g. once every minute):"
        echo "  $ crontab -e"
        echo -n "    >>> 0-59 * * * * bash -c '"
        echo -n "export NETWORK_PATH_LOG=\"${NETWORK_PATH_LOG}\"; "
        echo -n "source ${NETWORK_PATH}bashrc.sh && "
        echo    "$FUNCNAME <destination> [<gateway>]' >> /dev/null"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_dest="$1"
    param_gateway="$2"

    # set logfile
    logfile="${NETWORK_PATH_LOG}ping_${param_dest}.log"

    # get current date & time
    date_sec="$(date +"%s")"

    # ping gateway
    if [ "$param_gateway" != "" ]; then
        # info
        echo ""
        echo "pinging gateway ($param_gateway)"

        # ping, print info & eval result
        if ! ping -q -c 5 -w 10 "$param_gateway"; then
            return -2
        fi
    fi

    # info
    echo ""
    echo "pinging destination ($param_dest)"

    # ping
    result="$(ping -q -c 5 -w 10 "$param_dest")";
    error="$?";

    # output on screen
    echo "$result";

    # check data
    dest_delay="$(echo "$result" | grep "rtt" | grep -o -E "[0-9\.]+" | \
        head --lines=-2 | tail --lines=1)"
    #if [ "$dest_delay" == "" ]; then
    #    dest_delay="-"
    #fi

    #dest_count="$(echo "$result" | \
    #    grep -o -e "[0-9] received" | grep -o -e [0-9])"
    #if [ "$dest_count" == "" ]; then
    #    dest_count="-"
    #fi

    # log to file
    if [ "$error" -ne 0 ] || [ "$dest_delay" == "" ]; then
        dest_delay="9999"
    fi
    echo "$date_sec $dest_delay" >> "$logfile"

    # print info & return in case of error
    if [ "$error" -ne 0 ]; then
        echo "$FUNCNAME: error from ping ($error)"
        return -3
    fi
}

# 2021 01 06
function network_log_list() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "Lists all created logfiles in $NETWORK_PATH_LOG."
        echo ""
        echo "See also:"
        echo "  $ $(network_log_ping -h)"
        echo "  $ $(network_log_plot -h)"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    echo "Logfiles in $NETWORK_PATH_LOG:"
    (cd "${NETWORK_PATH_LOG}" && ls -1t ping_*.log 2> /dev/null)
}

# 2021 03 21
function network_log_plot() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <destination>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: destination address (e.g. 192.168.1.123)"
        echo "         May also be given as a hostname (e.g. egon.local)."
        echo "Plots the ping statistics for a given destination."
        echo "(e.g. the past 24h)"
        echo "The plotting can be done via crontab (e.g. once every hour):"
        echo "  $ crontab -e"
        echo -n "    >>> 57   * * * * bash -c '"
        echo -n "export NETWORK_PATH_LOG=\"${NETWORK_PATH_LOG}\"; "
        echo -n "cd <image-path> && "
        echo -n "source ${NETWORK_PATH}bashrc.sh && "
        echo    "$FUNCNAME <destination>' >> /dev/null"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_dest="$1"

    # check logfile
    logfile="${NETWORK_PATH_LOG}ping_${param_dest}.log"
    if [ ! -e "$logfile" ]; then
        echo "logfile \"$logfile\" does not exist"
        return -2
    fi

    # get output filename
    output_file="$(date +"%Y_%m_%d")_${param_dest}.png"

    # get current timezone offset
    offset="$(date +%z)"
    offset="$(( ${offset:0:1}((${offset:1:2} * 60) + ${offset:3:2}) * 60 ))"

    # call gnuplot
    gnuplot -e "
        set terminal pngcairo size 1920,1080 enhanced font 'Verdana,16';
        set output '${output_file}';

        set timefmt '%s';
        set xdata time;
        set xrange [time(0) - 24*60*60:];
        set format x '%H:%M';
        set xlabel 'Time';

        set logscale y;
        set yrange [1:10000];
        set ylabel 'Ping in milliseconds';

        set grid;
        plot '${logfile}' using (\$1 + ($offset)):2 title '';
    "

    if [ $? -eq 0 ]; then
        echo "created image ${output_file}"
    else
        echo "error using gnuplot :-("
    fi

    #set terminal svg  size 1920,1080 enhanced font 'Verdana,16';
    #set format x '%d.%m.%y';
    #set xlabel 'Date';
}
