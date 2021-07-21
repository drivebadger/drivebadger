#!/bin/bash
. /opt/drivebadger/internal/mobile/functions

BUS=`echo $DEVNAME |cut -d'/' -f4 |sed 's/^0*//'`
DEV=`echo $DEVNAME |cut -d'/' -f5 |sed 's/^0*//'`
PORT="$BUS,$DEV"

lock "badger-mtp-$BUS-$DEV"

camera=`/opt/drivebadger/internal/generic/ptp/list-mtp-devices.sh |grep :$PORT$ |cut -d: -f1`
if [ "$camera" = "" ]; then exit 0; fi   # unexpected error, resume on next event

logger "plugged $camera (recognized as MTP storage)"
target_directory=`/opt/drivebadger/internal/mobile/get-target-directory.sh`
if [ -s $target_directory/$camera.log.finish ]; then exit 0; fi   # device already processed (at least started), resume next day


show "mtp_device_detected"

mkdir -p /media/mtp/$camera
jmtpfs -device=$PORT /media/mtp/$camera

show "user_rsync_started"
logger "plugged $camera (syncing to $target_directory/$camera)"

rsync -av \
	--exclude cache/ \
	--exclude .cache/ \
	--exclude .facebook_cache/ \
	--exclude debug_log/ \
	--exclude '*.mp3' \
	--exclude '*.MP3' \
	/media/mtp/$camera $target_directory >>$target_directory/$camera.log 2>$target_directory/$camera.stderr

sync
logger "plugged $camera (sync finished)"
show "user_operation_finished"

logger "attempting to unmount /media/mtp/$camera"
umount /media/mtp/$camera

if [ ! -d $target_directory/$camera ] || [ "`find $target_directory/$camera -type f`" = "" ] || [ `stat -c %s $target_directory/$camera.log` -lt 300 ]; then
	logger "plugged $camera (apparently not agreed on file access yet, repeating scan)"
	mv -f $target_directory/$camera.log $target_directory/$camera.log.error
elif [ "`grep -v 'some files/attrs were not' $target_directory/$camera.stderr |grep -v link_stat |grep -v /.android_secure`" != "" ]; then
	logger "plugged $camera (sync interrupted)"
	mv -f $target_directory/$camera.log $target_directory/$camera.log.error
else
	date >$target_directory/$camera.log.finish
fi

logger "badger execution finished for camera $camera"
show "mtp_device_processed"
