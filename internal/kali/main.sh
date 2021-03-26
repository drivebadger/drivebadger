#!/bin/bash

perdev=`/opt/drivebadger/internal/kali/get-persistent-partitions.sh |head -n 1`

if [ "$perdev" != "" ]; then
	target_partition=`basename $perdev`
	target_drive=`/opt/drivebadger/internal/generic/get-partition-drive.sh $target_partition`

	target_raw_device=`/opt/drivebadger/internal/generic/get-raw-device.sh $perdev`  # sdb3 or dm-0
	logger "persistent partition $perdev on device $target_raw_device"

	id=`/opt/drivebadger/internal/generic/get-computer-id.sh`
	target_root_directory=`/opt/drivebadger/internal/kali/get-target-directory.sh $target_partition`
	target_directory=$target_root_directory/$id

	mkdir -p $target_directory
	/opt/drivebadger/internal/generic/dump-debug-files.sh $target_directory

	for uuid in `ls /dev/disk/by-uuid`; do
		tmp=`readlink /dev/disk/by-uuid/$uuid`
		current_partition=`basename $tmp`  # dm-0 is handled properly below, but dm-1 etc. not - fix before reusing this code in different context
		current_drive=`/opt/drivebadger/internal/generic/get-partition-drive.sh $current_partition`

		if [ "$current_partition" = "$target_raw_device" ] || [ "$current_partition" = "$target_partition" ]; then
			logger "skipping UUID=$uuid (partition $current_partition matches target $target_partition)"
		elif [ "$current_drive" = "$target_drive" ]; then
			logger "skipping UUID=$uuid (partition $current_partition lays on the same target drive $target_drive as target partition $target_partition)"
		else
			fs=`/opt/drivebadger/internal/generic/get-partition-fs-type.sh $current_partition`
			drive_serial=`/opt/drivebadger/internal/generic/get-drive-serial.sh $current_drive $target_directory`
			if [ "$fs" = "swap" ]; then
				logger "skipping UUID=$uuid (swap partition $current_partition)"
			elif [ "$fs" = "apfs" ]; then
				slices=`/opt/drivebadger/internal/generic/get-apfs-filesystems.sh /dev/$current_partition`
				for slice in $slices; do
					slid="${slice%:*}"
					slname="${slice##*:}"

					mountpoint=/media/$current_partition/$slid/mnt
					subtarget=$target_directory/$drive_serial/${current_partition}_${fs}_${slid}_${slname}
					mkdir -p $mountpoint $subtarget

					if fsapfsmount -f $slid /dev/$current_partition $mountpoint >>$subtarget/rsync.log; then
						/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

						logger "copying UUID=$uuid (partition $current_partition filesystem $fs slice $slid ($slname), mounted as $mountpoint, target directory $subtarget)"
						nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
					fi
				done
			else
				mountpoint=/media/$current_partition/mnt
				subtarget=$target_directory/$drive_serial/${current_partition}_${fs}
				mkdir -p $mountpoint $subtarget

				# no specific support for encrypted drives (LUKS, loop-aes, TrueCrypt, VeraCrypt etc.) - just raise an error here
				if mount -t $fs -o ro /dev/$current_partition $mountpoint >>$subtarget/rsync.log; then
					/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

					logger "copying UUID=$uuid (partition $current_partition filesystem $fs, mounted as $mountpoint, target directory $subtarget)"
					nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
				fi
			fi
		fi
	done

	# now process encrypted drives

	for current_partition in `/opt/drivebadger/internal/kali/get-udev-unrecognized-devices.sh`; do
		current_drive=`/opt/drivebadger/internal/generic/get-partition-drive.sh $current_partition`
		drive_serial=`/opt/drivebadger/internal/generic/get-drive-serial.sh $current_drive $target_directory`

		logger "attempting to decrypt Bitlocker encrypted partition $current_partition"
		bitlocker_mount=/media/bitlocker/$current_partition
		mkdir -p $bitlocker_mount

		for recovery_key in `/opt/drivebadger/internal/generic/get-bitlocker-keys.sh`; do
			if dislocker /dev/$current_partition -p$recovery_key -- $bitlocker_mount >>$target_directory/$current_partition.log; then

				mountpoint=/media/$current_partition/mnt
				subtarget=$target_directory/$drive_serial/${current_partition}_bitlocker
				mkdir -p $mountpoint $subtarget
				echo $recovery_key >$subtarget/bitlocker.key

				if mount -o ro $bitlocker_mount/dislocker-file $mountpoint >>$subtarget/rsync.log; then
					/opt/drivebadger/internal/generic/process-hooks.sh $mountpoint $target_root_directory

					logger "copying BITLOCKER (partition $current_partition filesystem ntfs, mounted as $mountpoint, target directory $subtarget)"
					nohup /opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log
				fi

				umount $bitlocker_mount
			fi
		done
	done

	logger "finished processing drives and partitions"
fi
