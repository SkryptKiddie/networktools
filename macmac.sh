#!/bin/zsh
# MacOS mac address changer

IFACE="en0" # network interface
newMac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//') # generate valid mac address

if [ "$EUID" -ne 0 ] # sudo check
  then echo "Please run as root"
  exit
fi

echo -e "[ \e[93m! \e[39m] Current MAC address"
ifconfig $IFACE | grep ether
echo -e "[ \e[93m! \e[39m] New MAC address"
print "$newMac"

echo -e "[ \e[92m# \e[39m] Changing MAC address on $IFACE..."
sudo ifconfig en0 ether $newMac
echo -e "[ \e[92m# \e[39m] Changed MAC address!"
ifconfig $IFACE | grep ether

echo -e "[ \e[93m! \e[39m] Reconnect to apply changes"
exit