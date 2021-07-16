#!/bin/sh
. /opt/drivebadger/internal/mobile/functions

BASE=`basename $DEVNAME`   # sdb3
DEVICE=/$DEVNAME           # /dev/sdb3

FALLBACK="/media/fallback"


if [ "`mount |grep -w /media/targets/$BASE`" != "" ]; then
	rm -f /media/target
	ln -s $FALLBACK /media/target
	umount -l /media/targets/$BASE

	logger "unplugged $DEVICE (reverting to fallback storage at $FALLBACK)"
	show "target_drive_disconnected"

elif [ "`mount |grep -w $DEVICE`" != "" ]; then
	umount -l $DEVICE

	logger "unplugged $DEVICE (seized drive)"
	show "user_drive_disconnected"
	show "target_drive_error_clear"
fi
