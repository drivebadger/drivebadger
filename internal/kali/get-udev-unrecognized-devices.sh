#!/bin/sh

recognized=`ls -l /dev/disk/by-uuid |grep -v ^total |rev |cut -d'/' -f1 |rev |sort |tr '\n' '|' |sed 's/.$//'`

(

ls -1 /dev/sd* 2>/dev/null
ls -1 /dev/nvme* 2>/dev/null

) |cut -d'/' -f3 |grep -v "sd.$" |grep -v "nvme.$" |grep -v "nvme.n.$" |egrep -v "($recognized)"
