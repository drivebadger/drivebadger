#!/bin/sh

update="
/opt/drives
`ls -d /opt/drives/config/* 2>/dev/null`
`ls -d /opt/drives/hooks/* 2>/dev/null`
"

for PD in $update; do
	/opt/drives/internal/git/pull.sh $PD
done
