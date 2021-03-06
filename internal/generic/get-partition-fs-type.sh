#!/bin/sh

partition=$1

udevadm info --query=all --name=/dev/$partition |grep ID_FS_TYPE |cut -d'=' -f2
