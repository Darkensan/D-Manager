# D-Manager
1 - Set-up Vps from scratch -

2 - Install from 1 to ~ Fs Nodes on U.16.04 -

3 - Update Denarius daemon to latest v3.4 branch -

4 - TO DO U18.04 install procedure -

5 - TO DO U18.04 dameon update -

6 - Monitor and control nodes status && Reboot nodes in case of need - more to do -

7 - TO DO Automatically populate denarius.conf with corrects IP and FS Privkey -



To add, and control node(s), it is suggested to install the "FS node(s)" using this script!

or

It is mandatory to change folder and name to core files:

move your node files into those dir:

denarius.conf --> /etc/masternodes/denarius1.conf ...2.conf ...3.coonf

denariusd --> /usr/local/bin/

Denarius data dir (./denarius ) --> /var/lib/masternodes/denarius1 ..2 ..3 


Important note:

Every .conf file need to be edited and proper informations added

To edit .conf file use the following command:

nano /etc/masternodes/denariusX.conf

Remember to change the X with the required node number: ...denarius1.conf

Edit the following lines: rpcpassword= & fortunastakeprivkey= & bind= & externalip=

To start a daemon use the following command:
 
denariusd -daemon -pid=/var/lib/masternodes/denariusX/denarius.pid -conf=/etc/masternodes/denariusX.conf -datadir=/var/lib/masternodes/denariusX
 
To stop any daemon use the following command:
 
denariusd -conf=/etc/masternodes/denariusX.conf stop
 
To get informations of any deamon use the following command:
 
denariusd -conf=/etc/masternodes/denariusX.conf getinfo
 
To check any FS's node status use the following command:
 
denariusd -conf=/etc/masternodes/denariusX.conf fortunastake status
 
 ***Remember to change the X with the required node number: ...denarius1.conf***


