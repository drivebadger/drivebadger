#!/bin/bash

drive=$1
directory=$2

if [ ! -f $directory/$drive.txt ]; then
	if [[ $drive =~ ^nvme ]]; then
		nvme id-ctrl /dev/$drive >$directory/$drive.txt
	else
		hdparm -I /dev/$drive >$directory/$drive.txt
	fi
fi

if [[ $drive =~ ^nvme ]]; then
	key=sn
else
	key=SerialNumber
fi

cat $directory/$drive.txt |tr -d ' \t' |grep ^$key: |cut -d':' -f2
