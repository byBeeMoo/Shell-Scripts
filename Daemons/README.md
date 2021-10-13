## Torips.sh

This daemon togheter with the shell script will update the list of tor nodes from https://github.com/SecOps-Institute/Tor-IP-Addresses 
and format them to be used as a ip block list for nginx, pasting it to /etc/nginx/

__!! Disclaimer !!__ \
An attacker could leverage some sort of hijacking to make the script download a non-expected file. \ 
IEX. through DNS Poisoning


__Additional info:__ \
.timer and .service may be placed under /etc/systemd/system/
torips.sh must have chmod 744 permissions
must be run by sudo
