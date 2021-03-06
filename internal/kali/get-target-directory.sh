#!/bin/sh

partition=$1

dt=`date +%Y%m%d`
echo /run/live/persistence/$partition/.files/.data/$dt
