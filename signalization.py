import os

import time

DEBUG = True

FATHER_EMAIL = "diamonder69gmail.com"
MOTHER_EMAIL = "lonata@icloud.com"
SON_EMAIL = "alexlember@gmail.com"

EMAIL_COMMAND = ("mailsend -to %s -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp "
                 "smtp.gmail.com -sub %s +cc +bc -v -user novokosino.home@gmail.com "
                 "-pass 'pass' -mime-type 'text/html' -msg-body /root/signalization_project/message-body.html")

alarm_state = False


def form_email_body(email, sub):
    email_command = EMAIL_COMMAND % (email, sub)
    return email_command


# All port setup as input (+external 10k pull-up resistors, default value for each port should be high).
def set_gpios():

    for x in range(18, 22):
        cmd = "echo %s > /sys/class/gpio/export" % str(x)
        os.system(cmd)
        logger(cmd)

        cmd = "echo in > /sys/class/gpio/gpio%s/direction" % str(x)
        os.system(cmd)
        logger(cmd)


# Method reading current state of input.
def get_gpio_state(port):
    cmd = "cat /sys/class/gpio/%s/value" % port
    f = os.popen(cmd)
    return str(f.read())


# Main send mail method (on state change)
def send_email(state_change, is_alarm):

    if is_alarm:
        if state_change.strip() == str("10"):
            cmd = "cat /root/signalization_project/signalization_alarm.html >> /root/signalization_project/message-body.html"
            sub = "'Alarm!!! Alarm!!! Alarm!!!'"
            os.system(cmd)
            logger(cmd)

            for x in range(0, 7):
                cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
                os.system(cmd)
                logger(cmd)

            cmd = "date >> /root/signalization_project/message-body.html"
            os.system(cmd)
            logger(cmd)

            f = os.popen(form_email_body(FATHER_EMAIL, sub))
            result = str(f.read())
            logger(result)

            f = os.popen(form_email_body(SON_EMAIL, sub))
            result = str(f.read())
            logger(result)

            # f = os.popen(form_email_body(MOTHER_EMAIL, sub, False)
            # result = str(f.read())
            # logger(result)

    else:
        sub = form_message_body(state_change)

        f = os.popen(form_email_body(FATHER_EMAIL, sub))
        result = str(f.read())
        logger(result)

        f = os.popen(form_email_body(SON_EMAIL, sub))
        result = str(f.read())
        logger(result)

        # f = os.popen(form_email_body(MOTHER_EMAIL, sub, False)
        # result = str(f.read())
        # logger(result)

    cmd = "echo "" > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)


# Method for form message-body
def form_message_body(state_change):
    sub = ""

    if state_change.strip() == str("01"):
        cmd = "cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html"
        sub = "'Alarm state: deactivated'"
        os.system(cmd)
        logger(cmd)

    elif state_change.strip() == str("10"):
        cmd = "cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html"
        sub = "'Alarm state: activated'"
        os.system(cmd)
        logger(cmd)

    for x in range(0, 7):
        cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
        os.system(cmd)
        logger(cmd)

    cmd = "date >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)
    return sub


# Greeting method send main at startup.
def send_start_email(current_input_state_alarm, current_input_state_activated):
    cmd = "cat /root/signalization_project/start-message-body.html > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    choose_picture(current_input_state_alarm, current_input_state_activated)

    # f = os.popen(form_email_body(MOTHER_EMAIL, result, False))
    # sub = str(f.read())
    # logger(result)

    for x in range(0, 7):
        cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
        os.system(cmd)
        logger(cmd)

    port18_state = get_gpio_state("gpio18").strip()
    port19_state = get_gpio_state("gpio19").strip()
    port20_state = get_gpio_state("gpio20").strip()
    port21_state = get_gpio_state("gpio21").strip()
    port22_state = get_gpio_state("gpio22").strip()

    port_states = ("<p>Port 18: type in, state %s</p>"
                   "<p>Port 19: type in, state %s</p>"
                   "<p>Port 20: type in, state %s</p>"
                   "<p>Port 21: type in, state %s</p>"
                   "<p>Port 22: type in, state %s</p>") % (
                      port18_state, port19_state, port20_state, port21_state, port22_state)

    cmd = "echo '%s' >> /root/signalization_project/message-body.html" % port_states
    os.system(cmd)
    logger(cmd)

    cmd = "echo '<br>' >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    cmd = "date >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    sub = "'Program initialization'"

    f = os.popen(form_email_body(FATHER_EMAIL, sub))
    result = str(f.read())
    logger(result)

    f = os.popen(form_email_body(SON_EMAIL, sub))
    result = str(f.read())
    logger(result)

    cmd = "echo "" > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)


def choose_picture(current_input_state_alarm, current_input_state_activated):
    if current_input_state_alarm.strip() == str("1") and current_input_state_activated.strip() == str("1"):
        cmd = "cat /root/signalization_project/signalization_off.html >> /root/signalization_project/message-body.html"
        os.system(cmd)
        logger(cmd)

    elif current_input_state_alarm.strip() == str("1") and current_input_state_activated.strip() == str("0"):
        cmd = "cat /root/signalization_project/signalization_on.html >> /root/signalization_project/message-body.html"
        os.system(cmd)
        logger(cmd)


# Event logger
def logger(message):
    os.system("echo '" + message + "' >> /root/signalization_project/log")
    os.system("date >> /root/signalization_project/log")
    os.system("echo "" >> /root/signalization_project/log")

    if DEBUG:
        print message
        print time.strftime("%H:%M:%S")
        print ""


# Main function, basic init, gpio poll.
def main():
    cmd = "echo "" > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    set_gpios()

    current_input_state_activated = get_gpio_state("gpio19").strip()
    logger("current activation state: " + current_input_state_activated)

    current_input_state_alarm = get_gpio_state("gpio20").strip()
    logger("current alarm state: " + current_input_state_alarm)

    send_start_email(current_input_state_alarm, current_input_state_activated)
    logger("setup completed")

    set_alarm_state(False)

    var = 1
    while var == 1:
        previous_input_state_alarm = current_input_state_alarm
        previous_input_state_activated = current_input_state_activated

        current_input_state_activated = get_gpio_state("gpio19").strip()
        current_input_state_alarm = get_gpio_state("gpio20").strip()

        if current_input_state_alarm != previous_input_state_alarm:
            new_alarm_state = not get_alarm_state()
            set_alarm_state(new_alarm_state)
            state_alarm = "%s%s" % (previous_input_state_alarm, current_input_state_alarm)
            logger("State alarm changed: " + state_alarm)
            send_email(state_alarm, True)

        if current_input_state_activated != previous_input_state_activated and get_alarm_state() is False:
            state_activated = "%s%s" % (previous_input_state_activated, current_input_state_activated)
            logger("State activated changed: " + state_activated)
            send_email(state_activated, False)


def set_alarm_state(state):
    global alarm_state
    alarm_state = state


def get_alarm_state():
    global alarm_state
    return alarm_state

# Main cycle start
main()
