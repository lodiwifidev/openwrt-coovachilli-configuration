#!/bin/sh
#

LOGFILE=/var/log/lodiwifi.log
SERVER_URL=https://hotspot.lodiwifi.net
SERVER_IP=192.168.200.254
DIRECTIVE_FILE=/tmp/directive
HS_HOSTNAME=`/bin/cat /proc/sys/kernel/hostname`
HS_MAC=`/sbin/ip link show eth0 | /usr/bin/awk -e '/^\s*link\//{print $2}' | /usr/bin/tr ':' '-'`
RSYNC=/usr/bin/rsync
LOGGER=/usr/bin/logger


$RSYNC -qrptv $SERVER_IP::hotspot-config/$HS_HOSTNAME/etc/ /etc 2>&1 | $LOGGER
$RSYNC -qrptv $SERVER_IP::hotspot-config/$HS_HOSTNAME/usr/ /usr 2>&1 | $LOGGER

 # Get administration scripts updates
$RSYNC -qrptv $SERVER_IP::hotspot-config/newhotspot.lodiwifi.net/root/ /root > $LOGFILE 2>&1

# Get ssl certificates updates used by coova-chilli
$RSYNC -qrptv $SERVER_IP::hotspot-config/newhotspot.lodiwifi.net/etc/lodiwifi/ssl/ /etc/lodiwifi/ssl > $LOGFILE 2>&1

# Get system-wide SSH keys updates
$RSYNC -qrptv $SERVER_IP::hotspot-config/newhotspot.lodiwifi.net/etc/dropbear/authorized_keys /etc/dropbear/authorized_keys > $LOGFILE 2>&1



