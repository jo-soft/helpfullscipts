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
AWK=$(which akw)
if [ -z $AWK ]; then
    echo cannot find akw
    exit 1
fi
BC=$(which bc)
if [ -z $BC ]; then
    echo cannot find bc
    exit 1
fi


function  get_cpu_usage_below_threashold {
    threshold=$1
    # Get the current CPU usage
    usage=$($MPSTAT 1 1 | $AWK '(/^[^a-zA-Z]+/) &&  ($12 ~  /[0-9,]+/) {print int(100 - $12)}')
    # Compared the current usage against the threshold
    result=$($BC -l <<< "$usage > $threshold")
    return $result
}

function ac_plugged_in {
    acpi_plug=$($ACPI -a | $AWK '/off-line$/')
    if [ -z "$acpi_plug" ]; then
  	return 0
    else
	return 1
    fi
}

function wait_for_cpu_usage_and_ac {
    while true ; do

	get_cpu_usage_below_threashold 20
	cpu_low=$?
	ac_plugged_in
	ac=$?
	if [ $cpu_low ==  0 ] && [ $ac == 0 ]; then
       	    break
	else
            sleep 1
	fi
    done
    return 0
}

wait_for_cpu_usage_and_ac
