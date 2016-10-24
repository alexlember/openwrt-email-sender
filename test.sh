#!/bin/sh


FATHER_EMAIL="diamonder69@gmail.com"
GREETING_SUB="Initialization"
DEACTIVATED_SUB="Deactivated"
ACTIVATED_SUB="Activated"
ALERT_SUB="Alarm!!! Alarm!!! Alarm!!!"

# Constants
GPIO_STATE_HIGH="1"
GPIO_STATE_LOW="0"
GPIO_STATE_LOW_TO_HIGH="01"
GPIO_STATE_HIGH_TO_LOW="10"


# Func combines email recipient and subject with email cmd template
# $1 - recipient, $2 - subject
form_email_body() {
    echo "3 point $1 $2"
    local email_command="mailsend -to $1 -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp smtp.gmail.com -sub $2 +cc +bc -v -user novokosino.home@gmail.com -pass 'Hs9oK0yv' -mime-type 'text/html' -msg-body /root/signalization_project/message-body.html"
    echo ${email_command}
}


# Method for form message-body
# $1 - state_changed
form_message_body_and_sub () {


    if [ $1 = ${GPIO_STATE_LOW_TO_HIGH} ]
    then
        echo ${DEACTIVATED_SUB}
    elif [ $1 = ${GPIO_STATE_HIGH_TO_LOW} ]
    then
        echo ${ACTIVATED_SUB}
    fi
}


send_email() {
    echo "1 point $1"
    local sub=$(form_message_body_and_sub $1)
    echo "2 point $1"
    for i in 0 1 2 3 4 5 6
    do
        echo "<br>"
    done
    echo "here! ${sub}"
    cmd=$(form_email_body ${FATHER_EMAIL} ${sub})
    echo "$cmd"
}

send_email ${GPIO_STATE_HIGH_TO_LOW}