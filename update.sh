#!/bin/sh

update="
/opt/drivebadger
`ls -d /opt/drivebadger/injectors/* 2>/dev/null`
`ls -d /opt/drivebadger/external/* 2>/dev/null`
`ls -d /opt/drivebadger/config/* 2>/dev/null`
`ls -d /opt/drivebadger/hooks/* 2>/dev/null`
"

for PD in $update; do
	/opt/drivebadger/internal/git/pull.sh $PD
done

if [ ! -d /run/live/persistence ]; then
	/opt/drivebadger/internal/mobile/rebuild-uuid-lists.sh
fi
