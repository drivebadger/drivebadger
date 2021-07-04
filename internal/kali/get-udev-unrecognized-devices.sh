#!/bin/sh

recognized=`ls -l /dev/disk/by-uuid |grep -v ^total |rev |cut -d'/' -f1 |rev |sort |tr '\n' '|' |sed 's/.$//'`

# 1. lsblk shows all drives and partitions, including not mounted
# - basically all /dev/sd* and /dev/nvme* devices + some other, not
# interesting entries (loop devices, LUKS encrypted volumes etc.)
#
# 2. grep " 0 part" leaves just partitions (UUID and non-UUID ones)
#
# 3. now filter out all partitions with size 128M - the intention
# is to remove Microsoft Reserved Partitions, that look like
# possibly encrypted, and trigger VeraCrypt key search, while
# not having any useful data
#
# https://en.wikipedia.org/wiki/Microsoft_Reserved_Partition
#
# this possibly removes also other (UUID) partitions of 128M size,
# but at this stage we are interested only in non-UUID ones, while
# UUID partitions are removed in the next step

lsblk |grep " 0 part" |tr -d '─├└' |grep -v 128M |cut -d' ' -f1 |egrep -v "($recognized)"


# TODO: filter out LUKS-encrypted Linux swap partitions:
# https://wiki.archlinux.org/title/Dm-crypt/Swap_encryption
#
# these are tricky, since:
# - they can have any size
# - they HAVE UUID while initialized and attached as swap at current system run
# - they have different UUID after each reboot
# - they no longer have UUID (and are totally unrecognized) after removing
#   them from /etc/crypttab and reboot
