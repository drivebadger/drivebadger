#!/bin/sh

cat /opt/drivebadger/config/*/bitlocker.keys 2>/dev/null |grep -v "^#" |grep -v ^$
