#!/bin/sh

src=$1
target=$2

for hook in `ls /opt/drives/hooks/*/hook.sh`; do
	$hook $src $target
done
