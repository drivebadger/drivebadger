#!/bin/sh

target_root_directory=$1
target_directory=$2
drive_serial=$3
current_partition=$4
uuid=$5


logger "attempting to decrypt LUKS encrypted partition $current_partition"
mountpoint=/media/$current_partition/mnt
subtarget=$target_directory/$drive_serial/${current_partition}_luks
mkdir -p $mountpoint $subtarget

for recovery_key in `/opt/drivebadger/internal/generic/keys/get-luks-keys.sh`; do
	echo "$recovery_key" |cryptsetup -q luksOpen /dev/$current_partition luks_$current_partition
	if [ -e /dev/mapper/luks_$current_partition ]; then

		echo $recovery_key >$subtarget/luks.key
		mount -o ro /dev/mapper/luks_$current_partition $mountpoint >>$subtarget/rsync.log
		/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

		logger "copying UUID=$uuid (partition $current_partition filesystem LUKS, mounted as $mountpoint, target directory $subtarget)"
		nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log

		cryptsetup luksClose luks_$current_partition
		break
	fi
done
