#!/bin/sh

opkg update
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade

touch /root/upgraded-`date '+%Y%m%d%H%M'`

reboot now
