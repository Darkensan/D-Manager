# D-Manager - U. 16.04 - 18.04
This script is made from an amateur with a really tiny knowledge about coding overall, not material for advanced user.

The main intention of this work, was to collect a bunch of commands, making them execute automatically,  and give a more accesible and comfortable experience to the majority of the amateur users as the writer same feel to be.

Starting from the great work made by @Buzzkillb with his guides and scripts, ( thank you sensei!!! ), and mixing it with other code found around the git ( thank you google!!! ), made up this work in the hope that it will be helpfull for someone.

The entire script was written directly from the vps using nano as editor, the commands and functions used are the only one learned so far. Will keep updating the script with more functionality and better overall coding language, as soon as i manage to dig more into scripting and unix :).


***Testest and working as intended on the following Vps providers:***

OVH - Done - Working as intended
Oher vps test coming soon...



***Enjoy:***


***Menu List:***

1 - D-Setup   - Prepare Vps and install dependancies

2 - D-Nodes   - Compile Daemon & Add one or more FS nodes - Master orv 3.4 Branch

3 - D-Update  - Build denariusd with latest Master/origin or v3.4 Branch Commits

4 - D-Keys    - Prompt for PrivKey - Populate denarius*X*.conf
 
5 - D-Ipv6    - Multi Ipv6 network interface auotonfiguration and .conf file population  (U.16.04 only)
 
6 - D-Onion   - Coming soon or later... Onion autoconfiguration

7 - D-Start   - Starts all installed FS nodes                     

8 - D-Stop    - Stops all installed FS nodes                     

9 - D-Monitor - Control & Reboot FS Nodes while you sleep - Maintenance
 
 
***To add, and control node(s), it is suggested to install them using this script!***
 
or
 
***It is mandatory to change folder and name to core files:***

move your existing node's files into those dir:

denarius.conf --> /etc/masternodes/denarius1.conf ...2.conf ...3.coonf

denariusd --> /usr/local/bin/

Denarius data dir ( ./denarius ) --> /var/lib/masternodes/denarius1 ..2 ..3 
 
 
 
***Important note:***

***In case of IPv6 usage, add the folliwing lines and use the form suggested:***

bind=[xxxx:xxxx:xxxx:xxxx::xxx]:9999

externalip=xxxx:xxxx:xxxx:xxxx::xxx
 
- To start a daemon use the following command:
 
denariusd -daemon -pid=/var/lib/masternodes/denarius***X***/denarius.pid -conf=/etc/masternodes/denarius***X***.conf -datadir=/var/lib/masternodes/denarius***X***
  
- To stop any daemon use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf stop
  
- To get informations of any deamon use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf getinfo
  
- To check any FS's node status use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf fortunastake status
  
 ***Remember to change the X with the required node number: ...denarius1.conf***


