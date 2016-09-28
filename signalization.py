import os


# Метод, в котором происходит установка входного порта.
def set_gpios():
    os.system("echo XX > /sys/class/gpio/export")
    os.system("echo 'echo XX > /sys/class/gpio/export' >> log")
    os.system("echo in > /sys/class/gpio/gpioXX/direction")
    os.system("echo 'echo in > /sys/class/gpio/gpioXX/direction' >> log")


# Метод, который считывает текущее состояние входного порта.
def get_gpio_state():
    f = os.popen("cat /sys/class/gpio/gpioXX/value")
    return str(f.read())


# Метод, который отправляет письмо.
def send_email(state_change):
    form_message_body(state_change)
    f = os.popen("mailsend -to user@gmail.com -from user@gmail.com -starttls -port 587 -auth -smtp"
                 " smtp.gmail.com -sub 'Signalization alert' +cc +bc -v -user user@gmail.com "
                 "-pass 'pass' -mime-type 'text/html' -msg-body ./message-body.html")
    result = str(f.read())
    os.system("echo '" + result + "' >> log")
    os.system("echo "" > message-body.html")


# Метод формирует тело письма.
def form_message_body(state_change):

    cmd = "cat warning.html > message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "echo '<b>' >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "echo '" + state_change + "' >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "echo '</b>' >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "echo '<br>' >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "echo '<br>' >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    cmd = "date >> message-body.html"
    print "cmd: " + cmd
    os.system(cmd)
    os.system("echo '" + cmd + "' >> log")

    print ""
    print ""


# Основная функция, где осуществляется настройка и дальнейший поллинг gpio.
def main():
	set_gpios()
	previous_input_state = get_gpio_state().strip()
	current_input_state = get_gpio_state().strip()
	os.system("date >> message-body.html")
	print "setup completed"
	var = 1
	while var == 1:
		previous_input_state = current_input_state
		current_input_state = get_gpio_state().strip()
		if current_input_state != previous_input_state:
			print ""
			print ""
			state = "%s -> %s" % (previous_input_state, current_input_state)
			print "State changed: " + state
			os.system("echo 'State changed: " + state + "' >> log")
			print send_email(state)
			
      
# Запуск основного цикла
main()
