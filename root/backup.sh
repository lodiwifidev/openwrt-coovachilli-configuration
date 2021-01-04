#!/bin/sh

rm /etc/config/*-opkg

cd /
tar c -z -v -f /tmp/hotspot-backup-`date '+%Y%m%d%H%M'`.tar.gz \
	etc/config \
	etc/crontabs \
	etc/dropbear/authorized_keys \
	etc/init.d/watchping \
	etc/lodiwifi \
	etc/openvpn \
	etc/passwd \
	etc/rc.local \
	etc/shadow \
	etc/ser2net.conf \
	etc/sysupgrade.conf \
	etc/zabbix_agentd.conf \
	etc/zabbix_agentd.conf.d \
	etc/zabbix_agentd.psk \
	root/ \
	usr/lib/watchping/watchping.sh \
