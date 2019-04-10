# D-Manager - U. 16.04 - 18.04
This script is made from an amateur with a really tiny knowledge about coding overall, not material for normal or advanced user.

The main intention of this work, was to collect a bunch of commands, making them execute automatically,  and give a more accesible and comfortable experience to the majority of the amateur users as the writer himself feel to be.

Starting from the great work made by @Buzzkillb with his guides and scripts, ( arigato gosaimasu Buzzk sensei!!! ), and mixing it with other code found around the net ( thank you google!!! ), made up this work in the hope that it will be helpfull for someone.
A last and special thanks goes to @manosv, for his patience and support during the development of this project. Thank you m8!!!

The entire script was written directly from the vps using nano as editor, the commands and functions used are the only one learned so far. Will keep updating the script with more functionality and better overall coding language, as soon as i manage to dig more into scripting and unix :).


***Testest and working as intended on the following Vps providers:***

OVH - Done - Working as intended

Oher vps test coming soon...




***Enjoy:***


***Menu List:***

1 - D-Setup   - Prepare Vps and install dependancies

2 - D-Nodes   - Compile Daemon & Add one or more FS nodes - Master or v 3.4 Branch

3 - D-Update  - Build denariusd with latest Master/origin or v3.4 Branch Commits

4 - D-Reset - Reset the selected FS Node DB to the lastest chaindat blocks

5 - D-Ipv4    - Multi Ipv4 network interface autoconfiguration and .conf file population
 
6 - D-Ipv6    - Multi Ipv6 network interface autoconfiguration and .conf file population 

7 - D-Onion   - Coming soon or later... Onion autoconfiguration

8 - D-Keys    - Prompt for PrivKey - Populate denarius*X*.conf

9 - D-Start   - Starts all installed FS nodes                     

0 - D-Stop    - Stops all installed FS nodes                     

11- D-Monitor - Control & reboot FS Node(s) - In maintenance till FS bugs will be fixed or i find a different solution for some outputs - "broken" version is working for some part, will share in D's discord if asked too.
 

NOTE:

Once D-IPv6 is used, you can not go back to an IPv4 scheme, unless using first:
ddelete.sh: to delete all files and folders created;
dmanager.sh: to install all nodes once more. 
Network .cfg will be compromised otherwise, and will need a manual editing.
Also denarius1.conf will be compromised and a manual edit necessary aswell. 



***To add, and control node(s), it is suggested to install them using this script!***
 
or
 
***It is mandatory to change folder and name to core files:***

move your existing node's files into those dir:

denarius.conf --> /etc/masternodes/denarius1.conf ...2.conf ...3.coonf

denariusd --> /usr/local/bin/

Denarius data dir ( ./denarius ) --> /var/lib/masternodes/denarius1 ..2 ..3 
 
 
 
 
 
***Coomands List:***
 
- To start a daemon use the following command:
 
denariusd -daemon -pid=/var/lib/masternodes/denarius***X***/denarius.pid -conf=/etc/masternodes/denarius***X***.conf -datadir=/var/lib/masternodes/denarius***X***
  
- To stop any daemon use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf stop
  
- To get informations of any deamon use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf getinfo
  
- To check any FS's node status use the following command:
 
denariusd -conf=/etc/masternodes/denarius***X***.conf fortunastake status
  
 ***Remember to change the X with the required node number: ...denarius1.conf***






If you like my work and find it usefull to manage your node(s), feel free to send a lil tip to this D address:

- DDbrmCVKLNzEyCzV9VNAU3mpUvsD5daa91

All donations collected will be used for community projects supported, time to time, from D's dev team

A 10% will go to support the poor beggars of discord community!!! Imho also Soy have the right to eat!



Thank you for reading and using this script :).



.
