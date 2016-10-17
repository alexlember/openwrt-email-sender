#!/bin/sh

DEBUG=true

FATHER_EMAIL="diamonder69@gmail.com"
GPIO_STATE_HIGH="01"

alert_state=true

function second {
    local funcresult=$FATHER_EMAIL
    echo $funcresult
}

function get_date {
    local OUTPUT=$(date)
    echo $OUTPUT
}

function main {
    current_input_state_alert="01"
    #echo $current_input_state_alert
    if [ $current_input_state_alert = $GPIO_STATE_HIGH ] ; then
        echo "xyu"
    else
        echo "nu3Da"
    fi

    if [ $DEBUG = true ] ; then
        echo ")|(ona"
    else
        echo "CyKA"
    fi
    #alert_state=false
    #echo "This is Main! $1 $DEBUG"
    #echo $DEBUG
}
res=$(get_date)
echo $res
#res="$(get_date)"
#get_date
#echo $?
#main
#echo $alert_state
#res=$(second)
#echo $res
