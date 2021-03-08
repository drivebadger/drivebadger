#!/bin/sh

src=$1
target=$2
lists=`/opt/drives/internal/generic/get-rsync-exclusion-lists.sh`

echo "### BEGIN `date +'%Y-%m-%d %H:%M:%S'` ###"

rsync -av $lists $src $target

echo "### END `date +'%Y-%m-%d %H:%M:%S'` ###"
umount $src