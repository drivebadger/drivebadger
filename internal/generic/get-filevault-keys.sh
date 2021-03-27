#!/bin/sh

cat /opt/drivebadger/config/*/filevault.keys 2>/dev/null |grep -v "^#" |grep -v ^$
