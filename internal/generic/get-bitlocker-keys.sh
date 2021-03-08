#!/bin/sh

cat /opt/drives/config/*/bitlocker.keys 2>/dev/null |grep -v "^#" |grep -v ^$
