#!/bin/sh

# give a chance to network configuration and DHCP, then continue
# but don't rely on them, since it could stop the whole solution
# (eg. on Wifi-only computers, where we don't know the password)
sleep 15

# additional time to allow smooth start of X environment
if [ "`ps aux |grep Xorg |grep -v grep`" != "" ]; then
	sleep 20
fi
