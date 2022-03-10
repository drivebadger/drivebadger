#!/bin/sh

target_root_directory=$1
target_directory=$2
keys_directory=$3
drive_serial=$4
current_partition=$5


mountpoint=/media/$current_partition/mnt
subtarget=$target_directory/$drive_serial/${current_partition}_vmfs
mkdir -p $mountpoint $subtarget


if vmfs6-fuse /dev/$current_partition $mountpoint >>$subtarget/rsync.log 2>>$subtarget/rsync.err; then
	/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

	logger "copying VMFS (partition $current_partition, mounted as $mountpoint, target directory $subtarget)"
	/opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log 2>>$subtarget/rsync.err
	umount $mountpoint
	logger "copied VMFS $current_partition"
fi
