#!/bin/sh

cat /opt/drivebadger/config/*/luks.keys 2>/dev/null |grep -v "^#" |grep -v ^$
