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

# Event logger
# $1 - message to log
function logger {
    echo $1 >> /root/signalization_project/log
    date >> /root/signalization_project/log
    echo "" >> /root/signalization_project/log

    if [ DEBUG = true ]; then
        echo $1
        date
        echo ""
    fi
}

function choose_alert_state {
    if [ current_input_state_alert = GPIO_STATE_HIGH ]
    then
        alert_state=false
    else
        alert_state=true
    fi
}wwe



# Method reading current state of input.
# $1 - port number to check state.
function get_gpio_state {
    OUTPUT="$(cat /sys/class/gpio/$1/value)"
    return "${OUTPUT}"
}

# Greeting method send main at startup.
function send_start_email {
    echo "Send start email"
}

#def send_start_email(current_input_state_alert, current_input_state_activated):
#    exec_cmd("cat /root/signalization_project/start-message-body.html > /root/signalization_project/message-body.html")
#
#    choose_picture(current_input_state_alert, current_input_state_activated)
#
#    for x in range(0, 7):
#        cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
#        os.system(cmd)
#
#    port18_state = get_gpio_state("gpio18")
#    port19_state = get_gpio_state("gpio19")
#    port20_state = get_gpio_state("gpio20")
#    port21_state = get_gpio_state("gpio21")
#    port22_state = get_gpio_state("gpio22")
#
#    port_states = ("<p>Port 18: type in, state %s</p>"
#                   "<p>Port 19: type in, state %s</p>"
#                   "<p>Port 20: type in, state %s</p>"
#                   "<p>Port 21: type in, state %s</p>"
#                   "<p>Port 22: type out, state %s</p>") % (
#                      port18_state, port19_state, port20_state, port21_state, port22_state)
#
#    cmd = "echo '%s' >> /root/signalization_project/message-body.html" % port_states
#    os.system(cmd)
#    logger(cmd)
#
#    cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
#    os.system(cmd)
#
#    exec_cmd("date >> /root/signalization_project/message-body.html")
#    try:
#        f = os.popen(form_email_body(FATHER_EMAIL, GREETING_SUB))
#        result = str(f.read())
#        logger(result)
#
#        f = os.popen(form_email_body(SON_EMAIL, GREETING_SUB))
#        result = str(f.read())
#        logger(result)
#
#        f = os.popen(form_email_body(MOTHER_EMAIL, GREETING_SUB))
#        logger(result)
#    except Exception as ex:
#        logger("Unexpected error: " + str(ex))
#
#    exec_cmd("echo "" > /root/signalization_project/message-body.html")



# Choose the initializing picture in order of port states.
# $1 - current_input_state_alert, $2 - current_input_state_activated
function choose_picture {
    if [ current_input_state_alert = GPIO_STATE_HIGH ]
    then
        if [ current_input_state_activated = GPIO_STATE_HIGH ]
        then
            cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html
        elif [ current_input_state_activated = GPIO_STATE_LOW ]
        then
            cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        fi
    else
        logger "Exception: unexpected alert state."
    fi
}

# Func combines email recipient and subject with email cmd template
# $1 - recipient, $2 - subject
function form_email_body {
    EMAIL_COMMAND="mailsend -to $1 -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp smtp.gmail.com -sub $2 +cc +bc -v -user novokosino.home@gmail.com -pass 'pass' -mime-type 'text/html' -msg-body /root/signalization_project/message-body.html"
    return "${EMAIL_COMMAND}"
}

# Main send mail method (on state change)
function send_email {
    echo "Send email"
}
#def send_email(state_change, is_alert):
#    if is_alert:
#        exec_cmd(
#            "cat /root/signalization_project/signalization_alert.html >> /root/signalization_project/message-body.html")
#        sub = ALERT_SUB
#
#        for x in range(0, 7):
#            cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
#            os.system(cmd)
#
#        exec_cmd("date >> /root/signalization_project/message-body.html")
#    else:
#        sub = form_message_body_and_sub(state_change)
#
#    try:
#        cmd = form_email_body(FATHER_EMAIL, sub)
#        logger("Point 0.5")
#        f = os.popen(cmd)
#        logger("Point 1")
#        result = str(f.read())
#        logger("Point2")
#        logger(result)
#    except Exception as ex:
#        logger("Father unexpected error: " + str(ex))
#
#    try:
#        cmd = form_email_body(SON_EMAIL, sub)
#        logger("Point 2.5")
#        f = os.popen(cmd)
#        logger("Point3")
#        result = str(f.read())
#        logger("Point4")
#        logger(result)
#
#    except Exception as ex:
#        logger("Son unexpected error: " + str(ex))
#
#    try:
#        cmd = form_email_body(MOTHER_EMAIL, sub)
#        logger("Point5")
#        f = os.popen(cmd)
#        logger("Point 6")
#        result = str(f.read())
#        logger("Point 7")
#        logger(result)
#
#    except Exception as ex:
#        logger("Son unexpected error: " + str(ex))
#
#    exec_cmd("echo "" > /root/signalization_project/message-body.html")


# Method for form message-body
# $1 - state_changed
function form_message_body_and_sub() {
    echo "Form message body"
    if [ $1 = GPIO_STATE_LOW_TO_HIGH ]
    then
        cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html
        logger "cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html"
        sub=DEACTIVATED_SUB
    elif [ $1 GPIO_STATE_HIGH_TO_LOW ]
    then
        cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html
        sub=ACTIVATED_SUB
    fi

    for i in 0 1 2 3 4 5 6
    do
        echo '<br>' >> /root/signalization_project/message-body.html
    done

    return "${sub}"
}

# All port setup as input (+external 10k pull-up resistors, default value for each port should be high).
function set_gpios {
    for i in 18 19 20 21 22
    do
        echo ${i} > /sys/class/gpio/export
        echo in > /sys/class/gpio/gpio${i}/direction
    done
    echo 22 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio22/direction
    echo '0' > /sys/class/gpio/gpio22/value
}

# Main function, basic init, gpio poll.
function main {


}
#    atexit.register(exit_handler)
#    exec_cmd("echo "" > /root/signalization_project/message-body.html")
#    set_gpios()
#
#    current_input_state_activated = get_gpio_state("gpio19")
#    logger("current activation state: " + current_input_state_activated)
#
#    current_input_state_alert = get_gpio_state("gpio20")
#    logger("current alert state: " + current_input_state_alert)
#
#    choose_alert_state(current_input_state_alert)
#    logger("Alert state global var: %s" % get_alert_state())
#
#    send_start_email(current_input_state_alert, current_input_state_activated)
#    logger("setup completed")
#
#    is_on = True
#    i = 0
#    # infinity loop
#    var = 1
#    while var == 1:
#        if i == 10:
#            if is_on:
#                os.system("echo 0 > /sys/devices/platform/leds-gpio/leds/gl-connect:green:lan/brightness")
#                is_on = False
#            else:
#                os.system("echo 1 > /sys/devices/platform/leds-gpio/leds/gl-connect:green:lan/brightness")
#                is_on = True
#            i = 0
#        else:
#            i = i + 1
#
#        port22_state = get_gpio_state("gpio22")
#        if port22_state == GPIO_STATE_LOW:
#            os.system("echo '1' > /sys/class/gpio/gpio22/value")
#        else:
#            os.system("echo '0' > /sys/class/gpio/gpio22/value")
#
#        previous_input_state_activated = current_input_state_activated
#        previous_input_state_alert = current_input_state_alert
#
#        current_input_state_activated = get_gpio_state("gpio19")
#        current_input_state_alert = get_gpio_state("gpio20")
#
#        if get_alert_state():
#            if current_input_state_alert != previous_input_state_alert:
#                set_alert_state(False)
#                logger("State alert changed to False")
#                send_email(GPIO_STATE_LOW_TO_HIGH, False)
#
#        if current_input_state_activated != previous_input_state_activated:
#            # time.sleep(0.05)
#            # contact bounce
#            current_input_state_activated = get_gpio_state("gpio19")
#            current_input_state_alert = get_gpio_state("gpio20")
#
#            state_activated = "%s%s" % (previous_input_state_activated, current_input_state_activated)
#            logger("State activated changed: " + state_activated)
#
#            if current_input_state_alert == GPIO_STATE_LOW:
#                logger("Alert GPIO went to low! Alert!")
#                set_alert_state(True)
#                logger("Alert state global var: %s" % get_alert_state())
#
#                send_email(state_activated, True)
#            else:
#                send_email(state_activated, False)
# Main cycle start

main


