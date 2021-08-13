#!/bin/sh

perdev=`/opt/drivebadger/internal/kali/get-first-persistent-partition.sh`

if [ "$perdev" != "" ]; then
	target_partition=`basename $perdev`
	keys_directory=`/opt/drivebadger/internal/kali/get-keys-directory.sh $target_partition`

	/opt/drivebadger/internal/generic/keys/show-key-stats.sh $keys_directory
fi
