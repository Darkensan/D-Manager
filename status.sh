#!/bin/bash
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
fsn=$((ifs+1))
denariusd -conf=/etc/masternodes/denarius1.conf getblockcount > /var/www/html/block.txt
#stop and start Installed FS Nodes
for ((i=1; i<$fsn; i++))
do
echo "$i"
denariusd -datadir=/var/lib/masternodes/denarius$i -conf=/etc/masternodes/denarius$i.conf fortunastake status > /var/www/html/$i.json
chmod -R 644 /var/www/html/*
sleep 5
done
