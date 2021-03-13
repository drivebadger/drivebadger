#!/bin/sh

for list in `ls /opt/drivebadger/config/*/exclude.list`; do
	echo -n " --exclude-from=$list"
done
