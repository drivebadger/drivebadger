#!/bin/sh

for list in `ls /opt/drives/config/*/exclude.list`; do
	echo -n " --exclude-from=$list"
done
