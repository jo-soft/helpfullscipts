#!/bin/bash

ACPI=$(which acpi)
if [ -z $ACPI ]; then
    echo cannot find acpi
    exit 1
fi
MPSTAT=$(which mpstat)
if [ -z $MPSTAT ]; then
    echo cannot find mpstat
    exit 1
fi
AWK=$(which awk)
if [ -z $AWK ]; then
    echo cannot find awk
    exit 1
fi
BC=$(which bc)
if [ -z $BC ]; then
    echo cannot find bc
    exit 1
fi

RSYNC=$(which rsync)
if [ -z $RSYNC ]; then
    echo cannot find rsync
    exit 1
fi
DEFAULT_RSYNC_OPTS="-aAXz --numeric-ids"
LOGGER=$(which logger)
if [ -z $LOGGER ]; then
    echo cannot find logger
    echo all error messages will be print to stderr
fi

CONFIG_FILE="jo-backup.conf"
GLOBAL_CONFIG_FILE="/etc/$CONFIG_FILE"
USER_CONFIG_FILE="$HOME/.$CONFIG_FILE"

function error_handler {
    MESSAGE=$1
    if [ -z "$MESSAGE" ]; then
	MESSAGE="something went wrong."
    fi
    if [ -n $LOGGER ] ; then
	$LOGGER -s -t ERROR  $MESSAGE
    else
	>&2 echo $MESSAGE
    fi
}

function warn_handler {
    MESSAGE=$1
    if [ -n $LOGGER ]; then
	$LOGGER -t WARN $MESSAGE
    elif [ -z $LOGGER ] || [ $VERBOSE -ge 1]; then
	>&2 echo $MESSAGE	
    fi
}

function debug {
    MESSAGE=$1
    if [ $VERBOSE -ge 2 ]; then
	echo $MESSAGE
    fi
}

function setup {
    # TODO: secrure config, avoid bash code to be executed in config file
    if [ -r $GLOBAL_CONFIG_FILE ]; then
	source $GLOBAL_CONFIG_FILE
	CONFIG_FOUND=1
	debug "Config loaded from $GLOBAL_CONFIG_FILE"
    fi
    if [ -r $USER_CONFIG_FILE ]; then
	source $USER_CONFIG_FILE
	CONFIG_FOUND=1
	debug "Config loaded from $USER_CONFIG_FILE"
    fi

    if [ -z $CONFIG_FOUND ]; then
	error_handler "No config files found"
	exit 1
    fi
}

function  get_cpu_usage_below_threashold {
    # Get the current CPU usage
    USAGE=$($MPSTAT 1 1 | $AWK '(/^[^a-zA-Z]+/) &&  ($12 ~  /[0-9,]+/) {print int(100 - $12)}')
    debug "CPU usage: $USAGE, threshold: $THREASHOLD"
    # Compared the current usage against the threshold
    return $($BC -l <<< "$USAGE > $THREASHOLD")
}

function ac_plugged_in {
    AC_STATUS=$($ACPI -a)
    debug "AC status: $AC_STATUS"
    ACPI_AC_STATUS=$(echo $AC_STATUS | $AWK '/off-line$/')
    return $([ -z "$ACPI_AC_STATUS" ])
}

function wait_for_cpu_usage_and_ac {
    while true ; do
	get_cpu_usage_below_threashold 20
	CPU_LOW=$?
	ac_plugged_in
	AC=$?
	if [ $CPU_LOW ==  0 ] && [ $AC == 0 ]; then
       	    break
	else
            sleep 1
	fi
    done
    return 0
}

function backup {
    debug "starting backup of $SRC to $DST"
    $RSYNC $DEFAULT_RSYNC_OPTS $RSYNC_OPTS  $SRC $DST
    debug "backup finished"
}

function main {   
    setup
    wait_for_cpu_usage_and_ac
    canBackup=$?
    if [ $canBackup == 0 ]; then
	backup
    else
	error_handler
    fi
}


main
