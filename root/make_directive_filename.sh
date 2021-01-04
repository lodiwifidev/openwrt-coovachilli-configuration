#!/bin/sh

MAC=`ip link show eth0 | awk -e '/^\s*link\//{print $2}' | tr ':' '-'`
HOSTNAME=`cat /proc/sys/kernel/hostname`

echo $HOSTNAME.$MAC
