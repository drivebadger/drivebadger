#!/bin/sh

apt-get install mc htop python-configparser nvme-cli dislocker libfsapfs-utils libfuse2

if [ ! -f /etc/rc.drivebadger ]; then
	cp /opt/drivebadger/internal/systemd/rc.drivebadger /etc
	cp /opt/drivebadger/internal/systemd/rc-drivebadger.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rc-drivebadger
	systemctl enable ssh
	systemctl set-default multi-user.target
fi
