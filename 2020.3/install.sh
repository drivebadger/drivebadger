#!/bin/sh

apt-get install mc htop nvme-cli dislocker libfsapfs-utils

configparser=/opt/drivebadger/config/compat/deb/python-configparser_3.5.0b2-3.1_all.deb
if [ -f $configparser ]; then
	dpkg -i $configparser
fi

if [ ! -f /etc/rc.drivebadger ]; then
	cp /opt/drivebadger/internal/systemd/rc.drivebadger /etc
	cp /opt/drivebadger/internal/systemd/rc-drivebadger.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rc-drivebadger
	systemctl enable ssh
	systemctl set-default multi-user.target
fi
