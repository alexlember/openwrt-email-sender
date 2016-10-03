import os

import time

DEBUG = True

FATHER_EMAIL = "xx@gmail.com"
MOTHER_EMAIL = "yy@icloud.com"
SON_EMAIL = "zz@gmail.com"

EMAIL_COMMAND = ("mailsend -to %s -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp "
                "smtp.gmail.com -sub %s +cc +bc -v -user novokosino.home@gmail.com "
                "-pass 'pass' -mime-type 'text/html' -msg-body /root/signalization_project/message-body.html")


def form_email_body(email, sub):
    email_command = EMAIL_COMMAND % (email, sub)
    return email_command


# Input port setup.
def set_gpios():

    cmd = "echo 18 > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpio18/direction"
    os.system(cmd)
    logger(cmd)

    cmd = "echo 19 > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpio19/direction"
    os.system(cmd)
    logger(cmd)

    cmd = "echo 20 > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpio20/direction"
    os.system(cmd)
    logger(cmd)

    cmd = "echo 21 > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpio21/direction"
    os.system(cmd)
    logger(cmd)

    cmd = "echo 22 > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpio22/direction"
    os.system(cmd)
    logger(cmd)


# Method reading current state of input.
def get_gpio_state(port):
    cmd = "cat /sys/class/gpio/%s/value" % (port)
    f = os.popen(cmd)
    return str(f.read())


# Main send mail method (on state change)
def send_email(state_change):
	sub = form_message_body(state_change)

    f = os.popen(form_email_body(FATHER_EMAIL, sub))
    result = str(f.read())
    logger(result)

    f = os.popen(form_email_body(SON_EMAIL, sub))
    result = str(f.read())
    logger(result)

    # f = os.popen(form_email_body(MOTHER_EMAIL, sub)
    # result = str(f.read())
    # logger(result)

    cmd = "echo "" > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)


# Method for form message-body
def form_message_body(state_change):
    cmd = "cat /root/signalization_project/warning.html > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)
    sub = ""

    if state_change.strip() == str("01"):
        cmd = "cat /root/signalization_project/zero_to_one.html >> /root/signalization_project/message-body.html"
        sub = "'State changed from low to high'"
        os.system(cmd)
        logger(cmd)

    elif state_change.strip() == str("10"):
        cmd = "cat /root/signalization_project/one_to_zero.html >> /root/signalization_project/message-body.html"
        sub = "'State changed from high to low'"
        os.system(cmd)
        logger(cmd)

    cmd = "date >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)
    return sub


# Greeting method send main at startup.
def send_start_email():
    cmd = "cat /root/signalization_project/start-message-body.html > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    port18_state = get_gpio_state("gpio18").strip()
    port19_state = get_gpio_state("gpio19").strip()
    port20_state = get_gpio_state("gpio20").strip()
    port21_state = get_gpio_state("gpio21").strip()
    port22_state = get_gpio_state("gpio22").strip()

    port_states = ("<p>Port 18: type in, state %s"
                   "<p>Port 19: type in, state %s"
                   "<p>Port 20: type in, state %s"
                   "<p>Port 21: type in, state %s"
                   "<p>Port 22: type in, state %s") % (port18_state, port19_state, port20_state, port21_state, port22_state)


    cmd = "cat '<br>' >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    cmd = "cat '%s' >> /root/signalization_project/message-body.html" % (port_states)
    os.system(cmd)
    logger(cmd)

    cmd = "cat '<br>' >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    cmd = "date >> /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)

    sub = "'Signalization activeted'"

    f = os.popen(form_email_body(FATHER_EMAIL, sub))
    result = str(f.read())
    logger(result)

    f = os.popen(form_email_body(SON_EMAIL, sub))
    result = str(f.read())
    logger(result)

    # f = os.popen(form_email_body(MOTHER_EMAIL, result))
    # sub = str(f.read())
    # logger(result)

    cmd = "echo "" > /root/signalization_project/message-body.html"
    os.system(cmd)
    logger(cmd)


def form_ports_state():



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
    current_input_state = get_gpio_state("gpio21").strip()
    logger("current state: " + current_input_state)
    send_start_email()
    logger("setup completed")

    var = 1
    while var == 1:
        previous_input_state = current_input_state
        current_input_state = get_gpio_state("gpio21").strip()
        if current_input_state != previous_input_state:
            state = "%s%s" % (previous_input_state, current_input_state)
            logger("State changed: " + state)
            send_email(state)


# Main cycle start
main()
