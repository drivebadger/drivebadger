#!/bin/sh

apt-get install mc htop python-configparser nvme-cli dislocker libfsapfs-utils libfuse2 libguestfs-tools vmfs-tools vmfs6-tools

if [ ! -f /etc/rc.drivebadger ]; then
	cp /opt/drivebadger/setup/systemd/rc.drivebadger /etc
	cp /opt/drivebadger/setup/systemd/rc-drivebadger.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rc-drivebadger
	systemctl enable ssh
	systemctl set-default multi-user.target
fi
