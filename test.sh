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

function choose_picture {
    #echo $1 $2
    echo "blah blah $1 blah $2 "
    if [ $1 = $GPIO_STATE_HIGH ]
    then
        if [ $2 = $GPIO_STATE_HIGH ]
        then
            cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html
        elif [ $2 = $GPIO_STATE_LOW ]
        then
            cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        fi
    else
        logger "Exception: unexpected alert state."
    fi
}

function test {
    #echo $1 $2
    choose_picture $1 $2
}


function get_gpio_state {
    local port_state=$(cat commands)
    echo ${port_state}
}

res=$(get_gpio_state)
echo $res
#test "one" "two"
#res=$(get_date)
#echo $res
#res="$(get_date)"
#get_date
#echo $?
#main
#echo $alert_state
#res=$(second)
#echo $res
