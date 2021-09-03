#!/bin/bash

if [ -e result.txt ]
then
	rm result.txt
fi

ifconfig | grep inet | head -n 1 | cut -d ' ' -f 10  > ip.txt
txt=$(cat ip.txt)
echo "${txt::-3}" > ip.txt
txt=$(cat ip.txt)
for i in {3..254};
do
	ip=$txt$i
	ping -c 1 $ip > /dev/null
	if [ $? -eq 0 ]
	then
		out="Host @ $ip is up."
		echo $out
		echo "$out" >> result.txt
	fi
done;
