#!/bin/sh
#
# LODI Wi-Fi Directive processing script
# Initiated by rc.local
#
#

LOGFILE=/var/log/lodiwifi.log
SERVER_URL=https://hotspot.lodiwifi.net
SERVER_IP=192.168.200.254
RSYNC_SECTION=hotspot-config
HS_HOSTNAME=`/bin/cat /proc/sys/kernel/hostname`
HS_MAC=`/sbin/ip link show eth0 | /usr/bin/awk -e '/^\s*link\//{print $2}' | /usr/bin/tr ':' '-'`
RSYNC=/usr/bin/rsync
LOGGER=/usr/bin/logger

DIRECTIVE_FILE=/tmp/$HS_HOSTNAME.$HS_MAC

while true
do
   echo Processing directive

   if [[ -f $DIRECTIVE_FILE ]]; then
      DIRECTIVE=`/bin/cat $DIRECTIVE_FILE | /usr/bin/awk '{print $1}'`
      DIRECTIVE_ARG1=`/bin/cat $DIRECTIVE_FILE | /usr/bin/awk '{print $2}'`
      DIRECTIVE_ARG2=`/bin/cat $DIRECTIVE_FILE | /usr/bin/awk '{print $3}'`

      echo Acting on directive: $DIRECTIVE $DIRECTIVE_ARG1 $DIRECTIVE_ARG2 | $LOGGER

      case "$DIRECTIVE" in 

         reconfig)
            echo Changing configuration from $HS_HOSTNAME to $DIRECTIVE_ARG1 ...
            $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/$DIRECTIVE_ARG1/etc/ /etc 2>&1 | $LOGGER
            $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/$DIRECTIVE_ARG1/usr/ /usr 2>&1 | $LOGGER

            echo Creating new VPN credentials from $DIRECTIVE_ARG1 and $DIRECTIVE_ARG2 ...
	    NEW_HOSTNAME=`echo $DIRECTIVE_ARG1 | /usr/bin/cut -d'.' -f1`
	    NEW_DOMAINNAME=`echo $DIRECTIVE_ARG1 | /usr/bin/cut -d'.' -f2-3`
	    echo $NEW_HOSTNAME > /etc/openvpn/Nexus.auth
	    echo $DIRECTIVE_ARG2 >> /etc/openvpn/Nexus.auth

            echo Rebooting in 10 seconds ... | $LOGGER
            /sbin/reboot  
            /bin/sleep 30
            ;;

         update_firmware)
   	      echo Upgrading firmware ... | $LOGGER
            /sbin/sysupgrade $SERVER_URL/files/lodi-wi-fi-hotspot-latest-newifi-d2-squashfs-sysupgrade.bin 2>&1 | $LOGGER
            ;;

         restart_service)
            echo Restarting $DIRECTIVE_ARG1
            /etc/init.d/$DIRECTIVE_ARG1 restart
            ;;

         reboot)
            echo Rebooting in 10 seconds ...
            /sbin/reboot -d 10
            ;;

         *)
            echo Unknown directive: $DIRECTIVE $DIRECTIVE_ARG1

      esac

      /bin/rm $DIRECTIVE_FILE
   fi

   # Get administration scripts updates
   $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/newhotspot.lodiwifi.net/root/ /root > $LOGFILE 2>&1

   # Get ssl certificates updates used by coova-chilli
   $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/newhotspot.lodiwifi.net/etc/lodiwifi/ssl/ /etc/lodiwifi/ssl > $LOGFILE 2>&1

   # Get system-wide SSH keys updates
   $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/newhotspot.lodiwifi.net/etc/dropbear/authorized_keys /etc/dropbear/authorized_keys > $LOGFILE 2>&1

   # To update MWAN 3 across all hotspots
   $RSYNC -qrptv $SERVER_IP::$RSYNC_SECTION/newhotspot.lodiwifi.net/etc/config/mwan3 /etc/config/mwan3 > $LOGFILE 2>&1

   /bin/sleep 30

done


