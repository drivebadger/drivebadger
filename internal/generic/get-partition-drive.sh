#!/bin/sh

partition=$1

echo $partition |sed 's/[0-9]//g'
