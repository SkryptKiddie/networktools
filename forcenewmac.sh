#!/bin/bash
# Joshek's MAC (and IP on DCHP) spoofer/generator

IFACE="wlo1" ## input network interface here
hexchars="0123456789ABCDEF" ## characters to be used for MAC address generation
end=$( for i in {1..10} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' ) ## generate the string
MAC=02$end ## prepend the 02 to the mac address

if [ "$EUID" -ne 0 ] # sudo check
  then echo "Please run as root"
  exit
fi

echo -e "[ \e[93m# \e[39m] Current MAC address" ## print current MAC address
ifconfig $IFACE | grep ether
echo -e "[ \e[93m# \e[39m] MAC address to be set - $MAC" ## print newly generated MAC address

read -p "Change MAC? Y/n" -n 1 -r
echo ## yes or no prompt
if [[ ! $REPLY =~ ^[Yy]$ ]]
then ## option yes
	echo -e "[ \e[91m- \e[39m] Stopping NetworkManager..." 
	sudo ifconfig $IFACE down ## take the IFACE offline
	sudo systemctl stop NetworkManager.service ## kill the NetworkManager.service
	echo -e "[ \e[92m! \e[39m] Stopped $IFACE interface!"

	echo -e "[ \e[93m* \e[39m] Setting new MAC address..."
	sudo ifconfig $IFACE hw ether $MAC ## change cloned MAC
	echo -e "[ \e[92m! \e[39m] Done!"

	echo -e "[ \e[93m* \e[39m] Reviving $IFACE..."
	sudo ifconfig $IFACE up ## bring IFACE back online
	sudo systemctl start NetworkManager.service ## start NetworkManager.service
	echo -e "[ \e[92m! \e[39m] $IFACE back up!"

	echo -e "[\e[93m?\e[39m] New MAC address"
	ifconfig $IFACE | grep ether
	exit
	
fi ## option no
	echo -e "[ \e[91m- \e[39m] Exitting..."
	exit
