#!/bin/sh
echo "check is wlan0 is up"

STA_IS_UP=0
[ -s /var/run/network/wpastate.wlan0 ] && STA_IS_UP=1
if [ ${STA_IS_UP} -eq 1 ]; then
	echo "wlan0 is in use, reset..."
	CHAN=$(cat /var/run/network/wpastate.wlan0 | cut -d' ' -f 2)
	echo "set AP channel to ${CHAN}..."
	sed -e "s/channel=.*/channel=${CHAN}/" -i /tmp/hostapd.conf
	ifdown wlan0
else
	echo "wlan0 is is not in use"
fi

echo "set AP interfaces up..."
ifup ap0

echo "start hostapd and bridge helper..."
/usr/sbin/hostapd -B -P /var/run/hostapd.ap0.pid /tmp/hostapd.conf

if [ $STA_IS_UP -eq 1 ]; then
	echo "reconfigure wlan0..."
	ifup wlan0
fi

echo "enable NAT"
iptables -F
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o ap0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i ap0 -o wlan0 -j ACCEPT

echo "restart dnsmasq"
killall dnsmasq ; dnsmasq

