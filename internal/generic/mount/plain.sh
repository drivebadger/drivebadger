#!/bin/sh

target_root_directory=$1
target_directory=$2
keys_directory=$3
drive_serial=$4
current_partition=$5
uuid=$6
fs=$7


mountpoint=/media/$current_partition/mnt
subtarget=$target_directory/$drive_serial/${current_partition}_${fs}
mkdir -p $mountpoint $subtarget

# no specific support for encrypted drives (loop-aes, TrueCrypt etc.) - just raise an error here
if mount -t $fs -o ro /dev/$current_partition $mountpoint >>$subtarget/rsync.log 2>>$subtarget/rsync.err; then
	/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

	logger "copying UUID=$uuid (partition $current_partition filesystem $fs, mounted as $mountpoint, target directory $subtarget)"
	/opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log 2>>$subtarget/rsync.err
	umount $mountpoint
fi
