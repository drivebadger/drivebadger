#!/bin/sh

apt-get install mc htop python-configparser nvme-cli dislocker

if [ ! -f /etc/rc.drivebadger ]; then
	cp rc.drivebadger /etc
	cp rc-drivebadger.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rc-drivebadger
	systemctl enable ssh
	systemctl set-default multi-user.target
fi
