#!/bin/sh
# From https://unix.slimdevices.narkive.com/oQMuFgl3/slimdevices-pi3-wifi-virtual-ap-bridged-that-really-works-for-me-worth-trying-on-pcp
freq_to_chan(){
	F="$1"
	[ $F -eq 2484 ] && echo 14 && return
	[ $F -lt 2484 ] && echo $(( (F-2407) / 5)) && return
	echo $(( F / 5 - 1000))
}

case $2 in
	"CONNECTED")
		F=$(/usr/sbin/wpa_cli -i ${1} status | grep freq | cut -d '=' -f 2 | xargs)
		[ -n "$F" ] && C=$(freq_to_chan ${F})
		[ -n "$C" ] && echo ${F} ${C} > /var/run/network/wpastate.${1}
	;;
		"DISCONNECTED")
		rm -f /var/run/network/wpastate.${1}
	;;
esac
exit 0