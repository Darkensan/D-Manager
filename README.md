# D-Manager - U. 16.04 - 18.04
1 - D-Setup   - Prepare Vps and install dependancies

2 - D-Compile - Add one or more FS nodes - v3.4

3 - D-Update  - Build denariusd with latest v3.4 Branch commits

4 - D-Keys    - Prompt for PrivKey - Populate denarius*X*.conf
 
5 - D-Start   - Start all installed FS nodes                     

6 - D-Stop    - Stops all installed FS nodes                     

7 - D-Monitor - Control & Reboot FS Nodes while you sleep
 
 
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


