#!/bin/sh

if [ -f /etc/rc.drives ]; then
	cp rc.drives /etc
else
	cp rc.drives /etc
	cp rc-drives.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rc-drives
	systemctl enable ssh
	systemctl set-default multi-user.target
fi
