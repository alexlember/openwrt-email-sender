Инструкция по настройке роутера и установке софта.

1. Введение

В наличии имеется роутер gl-net-6416A

Описание роутера https://wiki.openwrt.org/toh/gl-inet/gl-inet_64xx
Прошивку OpenWRT можно взять с ресурса http://www.gl-inet.com/downloads/
Картинки с роутером http://mysku.ru/blog/china-stores/26421.html

В рамках имеющихся распаянных проводках:

    GND  RX TX
      *  *  *
    |----------|
    |          |
    |          |
    |          |
    |          |
    |          |
    |          |
    |          |
    |----------|
  *  *  *  *  *  *
GND 20 19 18 22 21 (GPIO)

GND (ниж) - синий
GPIO :
20 -зеленый
19 - желтый
18 - оранжевый
22 - красный
21 - коричныевый

2. Установка и настройка прошивки OpenWRT

Предполагается, что роутер находится в состоянии дефолтной прошивки.
Втыкаем роутер в ноут через ethernet порт, далее заходим по ссылке 
https://wiki.openwrt.org/toh/gl-inet/gl-inet_64xx и производим действия, там описанные.
В результате  получим установленную прошивку OpenWRT.

Теперь необходимо выполнить следующие настройки через вебморду, доступную через браузер по адресу 192.168.1.1:
Переходим: 

Network > Interfaces, настройки LAN ethernet порта: 
Прописываем статический адрес в домашней сети, указываем адрес своего основного роутера в качестве default gateway
Network > DNS, DHCP: Убираем галочку с пункта Authoritative и прописываем в DNS forwardings адрес Default gatewat 
System > Administration, SSH access: указываем другой порт по умолчанию, ставим радиобаттон lan.

После проделанных манипуляций можно подключить роутер к основному роутеру в квартире в качестве клиента
и получать доступ к его веб-морде из основной сети по указанному статическому адресу.

Кроме того, можно получить доступ через терминал по SSH:
ssh root@192.168.x.x -p ssh_port
Нажимаем yes и вводим пароль от учетной записи root.
Можно алогиниться неограниченное кол-во раз, чтобы выполнять разные задачи одновременно.

пример отправки файла с ноута на роутер через scp (выполняется из директории с файлом):
scp -P 2222 filename root@192.168.x.x:/remote_directory
Вводим пароль и файлы пересылаются.

Для обратной отправки необходимо разрешить доступ по SSH на MAC OS. Это можно сделать в настройках Sharing, "Enable remote login"

3. Настройка софта

Как и во всех линуксах на OpenWRT есть менеджер установки пакетов. Его можно вызвать командой opkg.
Нам необходимо установить 3 пакета: 
python-light - облегченный язык программирования для разработки софта
ntpd - пакет для синронизации времени с удаленным сервером
mailsend - пакет для отправки писем из оболочки inux

Установка производится командами:
```
opkg update
opkg install python-light
opkg install ntpd
opkg install mailsend

```
Теперь необходимо перейти в директорию /etc/config/ и до полнить файл system до следующего:
```
config system
        option hostname 'OpenWrt'
        option zonename 'Europe/Moscow'
        option timezone 'MSK-3'
        option conloglevel '7'
        option cronloglevel '5'

config timeserver 'ntp'
        list server '0.openwrt.pool.ntp.org'
        list server '1.openwrt.pool.ntp.org'
        list server '2.openwrt.pool.ntp.org'
        list server '3.openwrt.pool.ntp.org'
        option enabled '1'
        option enable_server '0'

config led 'led_lan'
        option name 'LAN'
        option sysfs 'gl-connect:green:lan'
        option trigger 'netdev'
        option dev 'eth1'
        option mode 'link tx rx'

config led 'led_wlan'
        option name 'WLAN'
        option sysfs 'gl-connect:red:wlan'
        option trigger 'phy0tpt'
```
Выполняем следующие команды для настройки ntpd (можно подробно почитать здесь https://wiki.openwrt.org/doc/howto/ntp.client):
```
/etc/init.d/sysntpd disable
/etc/init.d/ntpd enable
/etc/init.d/ntpd start
netstat -l | grep ntp
```
Мы отключили системное время и подключили установленный пакет для синхронизации. 
Теперь необходимо перезагрузить роутер.
```
reboot
```

Краткая справка по полезным командам linux:
mkdir din_name - создать папку din_name
ls - просмотреть все папки в текущей директории
ls -al - тоже самое, в виде списка
cd dir_name - переход в папку dir_name, (если ее видно в текущей директории)
если нет, то всегда можно перейти используя абсолютные пути cd /root/../dir_name (переход в кореневую директорию cd /)
cd .. переход на один шаг вверх
cd - переход в предыдущую директорию
pwd - посмотреть полный путь до текущей директории
mv file_name dir_name перемещение файла file_name в директорию dir_name
cp file_name dir_name копирование файла file_name в директорию dir_name
chmod +x filename - сделать файл filename исполняемым
rm filename - удалить файл filename
rm -r dir_name - удалить директорию dir_name
date - текущее дата и время
uname -a - спрака о версии ОС

Команда по отправке письма с роутера:
mailsend -to user@gmail.com -from user@gmail.com -starttls -port 587 -auth -smtp smtp.gmail.com -sub test +cc +bc -v -user user@gmail.com -pass "your_password"
