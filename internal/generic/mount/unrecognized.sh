#!/bin/sh

target_root_directory=$1
target_directory=$2
keys_directory=$3
drive_serial=$4
current_partition=$5


logger "attempting to decrypt Bitlocker encrypted partition $current_partition"
mountpoint=/media/$current_partition/mnt
bitlocker_mount=/media/bitlocker/$current_partition
subtarget=$target_directory/$drive_serial/${current_partition}_encrypted
mkdir -p $mountpoint $subtarget $bitlocker_mount


for recovery_key in `/opt/drivebadger/internal/generic/keys/get-bitlocker-keys.sh`; do
	if dislocker /dev/$current_partition -p$recovery_key -- $bitlocker_mount >>$subtarget/rsync.log; then

		echo $recovery_key >$subtarget/bitlocker.key
		if [ "$drive_serial" != "" ] && ! grep -qFx $recovery_key $keys_directory/$drive_serial.bitlocker 2>/dev/null; then
			echo $recovery_key >>$keys_directory/$drive_serial.bitlocker
		fi

		if mount -o ro $bitlocker_mount/dislocker-file $mountpoint >>$subtarget/rsync.log; then
			/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

			logger "copying BITLOCKER (partition $current_partition filesystem ntfs, mounted as $mountpoint, target directory $subtarget)"
			nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
		fi

		umount $bitlocker_mount
		break
	fi
done


if [ -d /opt/drivebadger/external/ext-veracrypt ] && [ ! -f $subtarget/bitlocker.key ]; then
	logger "attempting to decrypt VeraCrypt encrypted system partition $current_partition"

	for recovery_key in `/opt/drivebadger/internal/generic/keys/get-veracrypt-keys.sh`; do
		if /opt/drivebadger/external/ext-veracrypt/wrapper.sh -t -k="" -p $recovery_key --pim=0 --mount-options=readonly,system --non-interactive /dev/$current_partition $mountpoint 2>/dev/null; then

			echo $recovery_key >$subtarget/veracrypt.key
			if [ "$drive_serial" != "" ] && ! grep -qFx $recovery_key $keys_directory/$drive_serial.veracrypt 2>/dev/null; then
				echo $recovery_key >>$keys_directory/$drive_serial.veracrypt
			fi

			/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

			logger "copying VERACRYPT (partition $current_partition filesystem ntfs, mounted as $mountpoint, target directory $subtarget)"
			nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
			break
		fi
	done
fi
