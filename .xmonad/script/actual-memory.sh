#!/bin/sh
#
# get actual used memory

mem="$(free --mega | awk '/^Mem:/ {print $3}')"
echo -e "$1$mem$2"
