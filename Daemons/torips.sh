#!/bin/bash

## Run as sudo

if [ ! -f ~/tornodes.txt ]
then
	curl https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-nodes.lst > ~/tornodes.txt
fi


curl https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-nodes.lst > ~/tornodes2.txt
DIFF=$(comm -3 ~/tornodes.txt ~/tornodes2.txt)

if [ "$DIFF" != "" ]
then
	mv ~/tornodes2.txt ~/tornodes.txt
	sed -e 's/^/deny /' -i ~/tornodes.txt;
	sed -e 's/$/;/' -i ~/tornodes.txt;
	mv ~/tornodes.txt /etc/nginx/blockips.conf
	service nginx restart
fi
