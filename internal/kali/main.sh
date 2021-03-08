#!/bin/sh

perdev=`/opt/drives/internal/kali/get-persistent-partitions.sh |head -n 1`

if [ "$perdev" != "" ]; then
	target_partition=`basename $perdev`
	target_drive=`/opt/drives/internal/generic/get-partition-drive.sh $target_partition`

	target_raw_device=`/opt/drives/internal/generic/get-raw-device.sh $perdev`  # sdb3 or dm-0
	logger "persistent partition $perdev on device $target_raw_device"

	id=`/opt/drives/internal/generic/get-computer-id.sh`
	target_root_directory=`/opt/drives/internal/kali/get-target-directory.sh $target_partition`
	target_directory=$target_root_directory/$id

	mkdir -p $target_directory
	/opt/drives/internal/generic/dump-debug-files.sh $target_directory

	for uuid in `ls /dev/disk/by-uuid`; do
		tmp=`readlink /dev/disk/by-uuid/$uuid`
		current_partition=`basename $tmp`  # dm-0 is handled properly below, but dm-1 etc. not - fix before reusing this code in different context
		current_drive=`/opt/drives/internal/generic/get-partition-drive.sh $current_partition`

		if [ "$current_partition" = "$target_raw_device" ] || [ "$current_partition" = "$target_partition" ]; then
			logger "skipping UUID=$uuid (partition $current_partition matches target $target_partition)"
		elif [ "$current_drive" = "$target_drive" ]; then
			logger "skipping UUID=$uuid (partition $current_partition lays on the same target drive $target_drive as target partition $target_partition)"
		else
			fs=`/opt/drives/internal/generic/get-partition-fs-type.sh $current_partition`
			if [ "$fs" = "swap" ]; then
				logger "skipping UUID=$uuid (swap partition $current_partition)"
			else
				drive_serial=`/opt/drives/internal/generic/get-drive-serial.sh $current_drive $target_directory`
				mountpoint=/media/$current_partition/mnt
				subtarget=$target_directory/$drive_serial/${current_partition}_${fs}
				mkdir -p $mountpoint $subtarget

				# no specific support for encrypted drives (LUKS, loop-aes, TrueCrypt, VeraCrypt etc.) - just raise an error here
				if mount -t $fs -o ro /dev/$current_partition $mountpoint >>$subtarget/rsync.log; then
					/opt/drives/internal/generic/process-hooks.sh $mountpoint $target_root_directory

					logger "copying UUID=$uuid (partition $current_partition filesystem $fs, mounted as $mountpoint, target directory $subtarget)"
					nohup /opt/drives/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
				fi
			fi
		fi
	done

	# now process encrypted drives

	for current_partition in `/opt/drives/internal/kali/get-udev-unrecognized-devices.sh`; do
		current_drive=`/opt/drives/internal/generic/get-partition-drive.sh $current_partition`
		drive_serial=`/opt/drives/internal/generic/get-drive-serial.sh $current_drive $target_directory`

		logger "attempting to decrypt Bitlocker encrypted partition $current_partition"
		bitlocker_mount=/media/bitlocker/$current_partition
		mountpoint=/media/$current_partition/mnt
		subtarget=$target_directory/$drive_serial/${current_partition}_bitlocker
		mkdir -p $bitlocker_mount $mountpoint $subtarget

		for recovery_key in `/opt/drives/internal/generic/get-bitlocker-keys.sh`; do
			if dislocker /dev/$current_partition -p$recovery_key -- $bitlocker_mount >>$subtarget/rsync.log; then
				echo $recovery_key >$subtarget/bitlocker.key
				if mount -o ro $bitlocker_mount/dislocker-file $mountpoint >>$subtarget/rsync.log; then
					/opt/drives/internal/generic/process-hooks.sh $mountpoint $target_root_directory

					logger "copying BITLOCKER (partition $current_partition filesystem ntfs, mounted as $mountpoint, target directory $subtarget)"
					nohup /opt/drives/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
					umount $bitlocker_mount
				fi
			fi
		done
	done

	logger "finished processing drives and partitions"
fi
