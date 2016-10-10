#!/bin/sh

opkg update
opkg install python-light
opkg update
opkg install ntpd
opkg update
opkg install mailsend

echo "" > /etc/config/system
cat system > /etc/config/system

/etc/init.d/sysntpd disable
/etc/init.d/ntpd enable
/etc/init.d/ntpd start
netstat -l | grep ntp

reboot