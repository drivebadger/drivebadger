#!/bin/sh
. /opt/drivebadger/internal/mobile/functions

BUS=`echo $DEVNAME |cut -d'/' -f4`
DEV=`echo $DEVNAME |cut -d'/' -f5`
PORT="usb:$BUS,$DEV"

lock "badger-ptp-$BUS-$DEV"

metadata_directory=`/opt/drivebadger/internal/mobile/get-metadata-directory.sh`
metafile=$metadata_directory/ptp-$BUS-$DEV.info

camera=`/opt/drivebadger/internal/generic/devices/get-ptp-device-name.sh $PORT $metafile`
if [ "$camera" = "" ]; then exit 0; fi   # PTP bus error, resume on next event, $metafile was deleted

logger "plugged $camera (recognized as PTP storage)"
target_directory=`/opt/drivebadger/internal/mobile/get-target-directory.sh`
if [ -s $target_directory/$camera.info ]; then exit 0; fi   # device already processed (at least started), resume next day


show "ptp_device_detected"
show "user_rsync_started"

mkdir -p $target_directory/$camera
cd $target_directory/$camera

logger "plugged $camera (downloading new files to $target_directory/$camera)"

mv -f $metafile $target_directory/$camera.info
/opt/drivebadger/internal/generic/devices/sync-ptp-device.sh $PORT $target_directory/$camera.log
sync

if [ ! -s $target_directory/$camera.log ] || grep -q '^For debugging messages' $target_directory/$camera.log; then
	logger "plugged $camera (apparently not agreed on file access yet, repeating scan)"
	mv -f $target_directory/$camera.log $target_directory/$camera.log.error
	mv -f $target_directory/$camera.info $target_directory/$camera.info.error
	rm -f $metafile
fi

logger "badger execution finished for camera $camera"

show "user_operation_finished"
show "ptp_device_processed"
