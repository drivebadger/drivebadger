#!/bin/sh

cat /opt/drivebadger/config/*/veracrypt.keys 2>/dev/null |grep -v "^#" |grep -v ^$
