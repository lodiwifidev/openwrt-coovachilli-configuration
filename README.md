# openwrt-coovachilli

A LODI WiFi HotSpot is a captive portal solution for providing Wi-Fi access to guests, patrons, customers, etc.
which use Coova-Chill and RFC6238 to generate one-time-passwords.  Please visit our website and FB page for 
more information.

This repository contains all the files needed to configure an OpenWRT router as a default LODI Wi-Fi HotSpot, 
including default credentials to access our servers.  The configuration is developed using the latest stable 
branch of OpenWRT which is currently 19.07p4.  The Newifi D2 router as the testbed.

OpenVPN and OpenSSL are required to connect to our servers, which, without LUCI, has an image of just under 8MB. 
If LUCI is included, the image will be slightly over 8MB on the testbed. LUCI is highly recommended for those 
new to OpenWRT. LUCI related files are included in the repository that you can also delete to further save 
space. Start with the SSL certificate files if you do.

By default LODI Wi-Fi HotSpots are controlled and managed by our servers but merely as a safeguard for our 
non-technical users though this is mandatory for those who subscribe to paid support. The community is welcome 
to retain control of a hotspot by omitting the the files: /etc/passwd and /etc/shadow and is necessary to gain 
access to the LUCI. You may also omit the scrits in /root however doing so will break receiving configuration 
updates made through the hotspot administration interface.  If you do, please also edit /etc/rc.local and 
comment out the line that starts the /root/directive.sh script.  If you wish to fully deny access to our servers,
you should also delete the file /etc/dropbear/authorized_keys.

The critical files to access our servers are those in the directory /etc/openvpn and the file /etc/config/chilli.  

