#!/bin/sh

target_root_directory=$1
target_directory=$2
drive_serial=$3
current_partition=$4
uuid=$5
fs=$6


mountpoint=/media/$current_partition/mnt
subtarget=$target_directory/$drive_serial/${current_partition}_${fs}
mkdir -p $mountpoint $subtarget

# no specific support for encrypted drives (loop-aes, TrueCrypt etc.) - just raise an error here
if mount -t $fs -o ro /dev/$current_partition $mountpoint >>$subtarget/rsync.log; then
	/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

	logger "copying UUID=$uuid (partition $current_partition filesystem $fs, mounted as $mountpoint, target directory $subtarget)"
	nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
fi
