#!/bin/sh
. /opt/drivebadger/internal/mobile/functions

BASE=`basename $DEVNAME`   # sdb3
DEVICE=/$DEVNAME           # /dev/sdb3

lock "badger-storage-$BASE"

keys_directory=`/opt/drivebadger/internal/mobile/get-keys-directory.sh`
metadata_directory=`/opt/drivebadger/internal/mobile/get-metadata-directory.sh`
metafile=$metadata_directory/$BASE.txt

udevadm info --query=all --name=$DEVICE >$metafile
SERIAL=`grep -w ID_SERIAL $metafile |cut -d'=' -f2`
USAGE=`grep -w ID_FS_USAGE $metafile |cut -d'=' -f2`
UUID=`grep -w ID_FS_UUID $metafile |cut -d'=' -f2`
FS=`grep -w ID_FS_TYPE $metafile |cut -d'=' -f2`

if ! echo $USAGE |egrep -q "(filesystem|disklabel|crypto)"; then
	mv -f $metafile $metafile.rejected
	exit 0
elif [ "$UUID" != "" ] && grep -q "UUID=$UUID" /etc/fstab; then
	logger "executing command: mount -U $UUID"
	mount -U $UUID || logger "mount by UUID with $UUID wasn't successful; return code $?"
	mv -f $metafile $metafile.fstab
	exit 0
elif [ "$UUID" != "" ] && [ "`echo $UUID |grep -ixFf /etc/drivebadger/drives/ignore.list`" != "" ]; then
	logger "ignoring $DEVICE ($UUID)"
	rm -f $metafile
	exit 0
elif [ "$UUID" != "" ] && [ "`echo $UUID |grep -ixFf /etc/drivebadger/drives/target.list`" != "" ]; then
	logger "mounting $DEVICE as target drive ($UUID)"
	mountpoint=/media/targets/$BASE
	mkdir -p $mountpoint
	if mount -t $FS -o sync,nodev,noatime,nodiratime $DEVICE $mountpoint; then
		mv -f $metafile $metafile.target
		rm -f /media/target
		ln -s $mountpoint /media/target
	fi
	show "target_ready"
	exit 0
fi

logger "$DEVICE contains filesystem type $FS ($UUID)"
show "operation_started" $DEVICE

target_directory=`/opt/drivebadger/internal/mobile/get-target-directory.sh`
mkdir -p $target_directory/$SERIAL
mv -f $metafile $target_directory/$SERIAL/$BASE.txt

if [ "$FS" = "swap" ]; then
	logger "skipping UUID=$UUID (swap partition $BASE)"
elif [ "$FS" = "exfat" ]; then
	/opt/drivebadger/internal/generic/mount/plain.sh        $target_directory $target_directory $keys_directory "$SERIAL" $BASE "$UUID" $FS
elif [ "$UUID" = "" ]; then
	/opt/drivebadger/internal/generic/mount/unrecognized.sh $target_directory $target_directory $keys_directory "$SERIAL" $BASE
elif [ "$FS" = "apfs" ]; then
	/opt/drivebadger/internal/generic/mount/apfs.sh         $target_directory $target_directory $keys_directory "$SERIAL" $BASE "$UUID"
elif [ "$FS" = "crypto_LUKS" ]; then
	/opt/drivebadger/internal/generic/mount/luks.sh         $target_directory $target_directory $keys_directory "$SERIAL" $BASE "$UUID"
else
	/opt/drivebadger/internal/generic/mount/plain.sh        $target_directory $target_directory $keys_directory "$SERIAL" $BASE "$UUID" $FS
fi

show "operation_finished" $DEVICE
logger "badger execution finished for $DEVICE ($UUID)"
sync
