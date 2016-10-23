#!/bin/sh

# Active constants
DEBUG=true

FATHER_EMAIL="diamonder69@gmail.com"
#FATHER_EMAIL_2="cpcdrom@yandex.ru"
MOTHER_EMAIL="lonata@icloud.com"
SON_EMAIL="alexlember@gmail.com"

GREETING_SUB="Initialization"
DEACTIVATED_SUB="Deactivated"
ACTIVATED_SUB="Activated"
ALERT_SUB="Alarm!!! Alarm!!! Alarm!!!"

# Constants
GPIO_STATE_HIGH="1"
GPIO_STATE_LOW="0"
GPIO_STATE_LOW_TO_HIGH="01"
GPIO_STATE_HIGH_TO_LOW="10"

# Private field
alert_state=false

# ==================================================================================================================

# Func combines email recipient and subject with email cmd template
# $1 - recipient, $2 - subject
form_email_body() {
    local email_command="mailsend -to $1 -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp smtp.gmail.com -sub $2 +cc +bc -v -user novokosino.home@gmail.com -pass 'pass' -mime-type 'text/html' -msg-body /root/signalization_project/message-body.html"
    echo ${email_command}
}

# Method for form message-body
# $1 - state_changed
form_message_body_and_sub () {
    if [ $1 = ${GPIO_STATE_LOW_TO_HIGH} ]
    then
        cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html
        logger "cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html"
        sub=${DEACTIVATED_SUB}
    elif [ $1 = ${GPIO_STATE_HIGH_TO_LOW} ]
    then
        cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        sub=${ACTIVATED_SUB}
    fi

    for i in 0 1 2 3 4 5 6
    do
        echo "<br>" >> /root/signalization_project/message-body.html
    done

    return ${sub}
}

# Choose the initializing picture in order of port states.
# $1 - current_input_state_alert, $2 - current_input_state_activated
choose_picture() {
    if [ $1 = ${GPIO_STATE_HIGH} ]
    then
        if [ $2 = ${GPIO_STATE_HIGH} ]
        then
            cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html
        elif [ $2 = ${GPIO_STATE_LOW} ]
        then
            cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        fi
    else
        logger "Exception: unexpected alert state."
    fi
}

# Greeting method send main at startup.
# $1 - current_input_state_alert, $2 - current_input_state_activated
send_start_email() {
    cat /root/signalization_project/start-message-body.html > /root/signalization_project/message-body.html
    logger "/root/signalization_project/start-message-body.html > /root/signalization_project/message-body.html"
    choose_picture $1 $2
    for i in 0 1 2 3 4 5 6
    do
        echo "<br>" >> /root/signalization_project/message-body.html
    done

    port18_state=$(get_gpio_state "gpio18")
    port19_state=$(get_gpio_state "gpio19")
    port20_state=$(get_gpio_state "gpio20")
    port21_state=$(get_gpio_state "gpio21")
    port22_state=$(get_gpio_state "gpio22")

    port_states="<p>Port 18: type in, state $port18_state</p><p>Port 19: type in, state $port19_state</p><p>Port 20: type in, state $port20_state</p><p>Port 21: type in, state $port21_state</p><p>Port 22: type out, state $port22_state</p>"
    echo ${port_states} >> /root/signalization_project/message-body.html
    logger "echo $port_states >> /root/signalization_project/message-body.html"
    echo "<br>" >> /root/signalization_project/message-body.html
    date >> /root/signalization_project/message-body.html

    cmd=$(form_email_body $FATHER_EMAIL $GREETING_SUB)
    eval "$cmd"
    logger "$cmd"


#    cmd=$(form_email_body $MOTHER_EMAIL $GREETING_SUB)
#    eval "$cmd"
#    logger "$cmd"


    cmd=$(form_email_body $SON_EMAIL $GREETING_SUB)
    eval "$cmd"
    logger ${cmd}

 #   echo "" > /root/signalization_project/message-body.html
}

# Main send mail method (on state change)
# $1 state changed, $2 is_alert
send_email() {
    if [ $2 = true ]
    then
        cat /root/signalization_project/signalization_alert.html >> /root/signalization_project/message-body.html
        logger "cat /root/signalization_project/signalization_alert.html >> /root/signalization_project/message-body.html"
        sub=${ALERT_SUB}
        for i in 0 1 2 3 4 5 6
        do
            echo "<br>" >> /root/signalization_project/message-body.html
        done
        date >> /root/signalization_project/message-body.html
        logger "date >> /root/signalization_project/message-body.html"
    else
        sub=$(form_message_body_and_sub $1)
        cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        sub=${ACTIVATED_SUB}
    fi

    cmd=$(form_email_body $FATHER_EMAIL $sub)
    eval "$cmd"
    logger "$cmd"


#    cmd=$(form_email_body $MOTHER_EMAIL $sub)
#    eval "$cmd"
#    logger "$cmd"

    cmd=$(form_email_body $SON_EMAIL $sub)
    eval "$cmd"
    logger "$cmd"

    echo "" > /root/signalization_project/message-body.html

}


# $1 - current_input_state_alert
choose_alert_state() {
    if [ $1 = ${GPIO_STATE_HIGH} ]
    then
        alert_state=false
    else
        alert_state=true
    fi
}


# Method reading current state of input.
# $1 - port number to check state.
get_gpio_state() {
    local port_state=$(cat /sys/class/gpio/$1/value)
    echo ${port_state}
}

# All port setup as input (+external 10k pull-up resistors, default value for each port should be high).
set_gpios() {
    for i in 18 19 20 21 22
    do
        echo ${i} > /sys/class/gpio/export
        echo in > /sys/class/gpio/gpio${i}/direction
    done
    echo 22 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio22/direction
    echo "0" > /sys/class/gpio/gpio22/value
}

# Event logger
# $1 - message to log
logger() {
    echo "$1" >> /root/signalization_project/log
    date >> /root/signalization_project/log
    echo "" >> /root/signalization_project/log

    if [ ${DEBUG} = true ]; then
        echo "$1"
        date
        echo ""
    fi
}

# Main function, basic init, gpio poll.
main() {
    echo "" > /root/signalization_project/message-body.html
    set_gpios
    current_input_state_activated=$(get_gpio_state "gpio19")
    logger "current activation state: $current_input_state_activated"

    current_input_state_alert=$(get_gpio_state "gpio20")
    logger "current alert state: $current_input_state_alert"

    choose_alert_state ${current_input_state_alert}
    logger "Alert state global var: $alert_state"

    #send_start_email $current_input_state_alert $current_input_state_activated
    logger "setup completed"

    green_led_is_on=true
    i=0
    while :
    do
        if [ ${i} = 10 ]
        then
            if [ ${green_led_is_on} = true ] ; then
             green_led_is_on=false
             echo "green led is false"
             echo 0 > /sys/devices/platform/leds-gpio/leds/gl-connect:green:lan/brightness

            else
                green_led_is_on=true
                echo "green led is true"
                echo 1 > /sys/devices/platform/leds-gpio/leds/gl-connect:green:lan/brightness
            fi
            i=0
        else
            i=$((i+1))
            echo ${i}
        fi

        previous_input_state_activated=${current_input_state_activated}
       # echo "previous activated $previous_input_state_activated"
        previous_input_state_alert=${current_input_state_alert}
       # echo "previous alert $previous_input_state_alert"
        current_input_state_activated=$(get_gpio_state "gpio19")
       # echo "current activated $current_input_state_activated"
        current_input_state_alert=$(get_gpio_state "gpio20")
       # echo "current alert $current_input_state_alert"

        if [ "${alert_state}" = true ]
        then
            if [ "${current_input_state_alert}" != "${previous_input_state_alert}" ] ; then
                alert_state=false
                logger "State alert changed to False"
                #send_email ${GPIO_STATE_LOW_TO_HIGH} false
            fi
        fi

        if [ "${current_input_state_activated}" != "${previous_input_state_activated}" ] ; then
            current_input_state_activated=$(get_gpio_state "gpio19")
            current_input_state_alert=$(get_gpio_state "gpio20")
            state_activated="$previous_input_state_activated$current_input_state_activated"
            logger "State activated changed: ${state_activated}"
            if [ "${current_input_state_alert}" = ${GPIO_STATE_LOW} ] ; then
                logger "Alert GPIO went to low! Alert!"
                set_alert_state=true
                logger "Alert state global var: $alert_state"
                #send_email $state_activated true
            else
                logger "regular email send"
                #send_email $state_activated false
            fi
        fi
    done
}

main

#res=$(form_email_body $FATHER_EMAIL test)
#echo $res

#res=$(get_gpio_state "gpio22")
#echo $res

#echo $alert_state
#choose_alert_state 0
#echo $alert_state

#logger "lalala"
#send_start_email 1 0

#choose_alert_state
