#!/bin/sh
. /opt/drivebadger/internal/mobile/functions

if [ -d /opt/drivebadger/external/ext-mobile-drivers ]; then
	/opt/drivebadger/external/ext-mobile-drivers/init.sh
fi

show "ready"
