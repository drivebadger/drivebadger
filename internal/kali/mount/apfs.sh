#!/bin/bash

target_root_directory=$1
target_directory=$2
drive_serial=$3
current_partition=$4
uuid=$5


slices=`/opt/drivebadger/internal/generic/apple/get-apfs-filesystems.sh /dev/$current_partition`
for slice in $slices; do
	slid="${slice%:*}"
	slname="${slice##*:}"

	mountpoint=/media/$current_partition/$slid/mnt
	subtarget=$target_directory/$drive_serial/${current_partition}_apfs_${slid}_${slname}
	mkdir -p $mountpoint $subtarget

	if /opt/drivebadger/internal/generic/apple/mount-apfs-filesystem.sh /dev/$current_partition $slid $mountpoint >>$subtarget/rsync.log; then
		/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

		logger "copying UUID=$uuid (partition $current_partition filesystem APFS slice $slid ($slname), mounted as $mountpoint, target directory $subtarget)"
		nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
	fi
done
