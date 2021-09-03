#!/bin/bash


function installEssentials {
	echo -e "INSTALLING REQUIREMENTS...\n\n"
	apt -qq install -y isc-dhcp-server > /dev/null 2>&1
	apt -qq install -y hostapd > /dev/null 2>&1
}

function getVars {
	# no serveix si la ruta de ip_forward es sempre la mateixa # find / -name ip_forward 2> /dev/null 1>> res.txt
	$(ip a | grep ^[1-4] | cut -d ':' -f2 | cut -d ' ' -f2 | grep -v ^[lo,do] > res.txt)
	export ethernetInterface=$(cat res.txt | awk 'NR==1')
	export wlanInterface=$(cat res.txt | awk 'NR==2')
	export dir=$(pwd)
	rm res.txt
}

function enableTrafficForwarding {

	echo -e "$(cat /etc/network/interfaces | head -n 2)
auto $wlanInterface
iface $wlanInterface inet static
	address    192.168.1.1
	netmask    255.255.255.0" > /etc/network/interfaces
	
	echo -e "#!/bin/bash\necho '1' > /proc/sys/net/ipv4/ip_forward\niptables -A FORWARD -j ACCEPT\niptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o $ethernetInterface -j MASQUERADE" > routing.sh
}

function enableHostapd {
	# SETUP HOSTAPD CONFIG FILE AND CREATE HOSTAPD.SH SCRIPT TO LAUNCH AP #
	echo -e "#!/bin/bash\n\nhostapd -B $dir/hostapd.conf &\n" > hostapd.sh
}

function enableDHCP {
	# SETUP DHCP RUNNING INTERFACE AND DHCPD.CONF CONFIG FILE #
	echo -e "INTERFACESv4='$wlanInterface'" > /etc/default/isc-dhcpd-server

	echo -e "authoritative;\ndefault-lease-time 3600;\nmax-lease-time 3600;\noption domain-name-servers 8.8.8.8;\noption routers 192.168.1.1;\noption subnet-mask 255.255.255.0;\noption broadcast-address 192.168.1.255;\n\nsubnet 192.168.1.0 netmask 255.255.255.0 {\n\trange 192.168.1.200 192.168.1.254;\n}\n" > /etc/dhcp/dhcpd.conf
	systemctl restart networking
}

function setupDaemon {
	echo -e "[Unit]\nDescription=Routing IPV4 Forward Script\n\n[Service]\nExecStart='$dir/routing.sh'\nType=simple\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/routing.service

	echo "DAEMON_CONF='$dir/hostapd.conf'" > /etc/default/hostapd
	update-rc.d hostapd enable
	systemctl daemon-reload
	systemctl start isc-dhcp-server
	systemctl enable isc-dhcp-server
	systemctl start routing
	systemctl enable routing
}

if [ $(id -u) == 0 ]
then
	shopt -s nocasematch
	if [ "$(pwd | grep -o dades)" == "dades" ]
	then
	checkDir="dades"
	else
		checkDir="DADES"
	fi

	case "$checkDir" in
		"dades" )
			installEssentials
			getVars
			enableTrafficForwarding
			enableDHCP
			enableHostapd
			setupDaemon
			shopt -u nocasematch
			;;
		*)
			echo "EXECUTE THIS SCRIPT @ DADES DIR"
			;;
	esac
fi
