#!/bin/bash
n=0
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo $ifs
while [ $n -lt $ifs ]
do
PK=$(whiptail --title " [D] - Manager " --inputbox "Write FSn $((n+1)) PrivKey here:" 8 80 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus -eq 0 ]; then
   sed -i "s/XXX_key_XXX/"${PK}"/g" /etc/masternodes/denarius$((n+1)).conf;
   echo "FSn $((n+1)) PrivKey is:" $PK
else
   echo "You chose Cancel - Manually edit node's PrivKey into .conf file"
   sed -i 's/fortunastake=0/fortunastake=1/g' /etc/masternodes/denarius$((n+1)).conf;
fi
let n++
done

