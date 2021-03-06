#!/bin/sh

drive=$1
directory=$2

if [ ! -f $directory/$drive.txt ]; then
	hdparm -I /dev/$drive >$directory/$drive.txt
fi

grep -i serial $directory/$drive.txt |head -n 1 |cut -d':' -f2 |sed 's/[ \t]//g'
