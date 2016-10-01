import os

import time

DEBUG = True


# Input and output port setup.
def set_gpios():
    cmd = "echo YY > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo out > /sys/class/gpio/gpioYY/direction"
    os.system(cmd)
    logger(cmd)

    cmd = "echo XX > /sys/class/gpio/export"
    os.system(cmd)
    logger(cmd)

    cmd = "echo in > /sys/class/gpio/gpioXX/direction"
    os.system(cmd)
    logger(cmd)


# Method reading current state of input.
def get_gpio_state():
    f = os.popen("cat /sys/class/gpio/gpioXXS/value")
    return str(f.read())


# Main send mail method (on state change)
def send_email(state_change):
    form_message_body(state_change)
    f = os.popen("mailsend -to alexlember@gmail.com -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp"
                 " smtp.gmail.com -sub 'Signalization alert' +cc +bc -v -user novokosino.home@gmail.com "
                 "-pass 'pass' -mime-type 'text/html' -msg-body ./message-body.html")

    result = str(f.read())
    logger(result)

    cmd = "echo "" > message-body.html"
    os.system(cmd)
    logger(cmd)


# Method for form message-body
def form_message_body(state_change):
    cmd = "cat warning.html > message-body.html"
    os.system(cmd)
    logger(cmd)

    if state_change.strip() == str("01"):
        cmd = "cat zero_to_one.html >> message-body.html"
        os.system(cmd)
        logger(cmd)

    elif state_change.strip() == str("10"):
        cmd = "cat one_to_zero.html >> message-body.html"
        os.system(cmd)
        logger(cmd)

    cmd = "date >> message-body.html"
    os.system(cmd)
    logger(cmd)


# Greeting method send main at startup.
def send_start_email():
    cmd = "cat start-message-body.html > message-body.html"
    os.system(cmd)
    logger(cmd)

    cmd = "date >> message-body.html"
    os.system(cmd)
    logger(cmd)

    f = os.popen("mailsend -to alexlember@gmail.com -from novokosino.home@gmail.com -starttls -port 587 -auth -smtp"
                 " smtp.gmail.com -sub 'Signalization alert' +cc +bc -v -user novokosino.home@gmail.com "
                 "-pass 'pass' -mime-type 'text/html' -msg-body ./message-body.html")

    result = str(f.read())
    logger(result)

    cmd = "echo "" > message-body.html"
    os.system(cmd)
    logger(cmd)


# Event logger
def logger(message):
    os.system("echo '" + message + "' >> log")
    os.system("date >> log")
    os.system("echo "" >> log")

    if DEBUG:
        print message
        print time.strftime("%H:%M:%S")
        print ""


# Main function, basic init, gpio poll.
def main():

    cmd = "echo "" > message-body.html"
    os.system(cmd)
    logger(cmd)

    set_gpios()
    current_input_state = get_gpio_state().strip()
    logger("current state: " + current_input_state)
    send_start_email()
    logger("setup completed")

    var = 1
    while var == 1:
        previous_input_state = current_input_state
        current_input_state = get_gpio_state().strip()
        if current_input_state != previous_input_state:
            state = "%s%s" % (previous_input_state, current_input_state)
            logger("State changed: " + state)
            send_email(state)


# Main cycle start
main()
