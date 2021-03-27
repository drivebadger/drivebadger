#!/bin/sh

device=$1
slice=$2
mountpoint=$3

if fsapfsmount -f $slice $device $mountpoint; then
	exit 0
fi

for recovery_key in `/opt/drivebadger/internal/generic/get-filevault-keys.sh`; do
	if fsapfsmount -f $slice -p$recovery_key $device $mountpoint; then
		echo "### APFS key $recovery_key"
		exit 0
	fi
done

exit 1
