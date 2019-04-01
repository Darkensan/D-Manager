#!/bin/bash

# Setting a menu interface ( still to study and improve the general outputs  ) ~~~~~~~~~~~~~~~~~~~~   ~~ ~~ ~ ~~ ~ ~~ ~ ~~ ~ ~ ~
TEMP=/tmp/answer$$
whiptail --fb --title "[D] - Manager" --menu "      Ubuntu 16.04/18.04 Denarius's FS Nodes Manager :" 20 0 0\
					1 "D-Setup   - Prepare Vps and install dependancies"\
					2 "D-Compile - Add one or more FS nodes - v3.4 Branch"\
					3 "D-Update  - Build denariusd with latest v3.4 Branch commits"\
					4 "D-Monitor - Control & Reboot FS Nodes while you sleep" 2>$TEMP
choice=`cat $TEMP`
case $choice in
#Start to process the menu options
1)
Green="\033[0;32m";
Red="\033[0;31m";
Yellow="\033[1;33m";
Blue="\033[1;34m";
LGreen="\e[92m";
LRed="\e[91m";
LYellow="\e[93m";
LBlue="\e[94m";
LMagenta="\e[95m";
NC="\033[0m";

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo -e "${Red}\e[7m Ctrl-C caught...performing clean up      \e[25m ${NC}"
    echo -e "${Green}\e[7m Cleanup done                               \e[25m ${NC}"
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "\e[7m${LBlue}!!!                          D-Vps Installer                           !!!\e[25m${NC}";
echo -e "\n"
echo -e "${LGreen}\e[7m 1 - Setup VPS and install dependancies                                  \e[25m ${NC}"
echo -e "${LYellow}\e[7m Updating linux packages & dependencies                                  \e[25m ${NC}"
	sudo add-apt-repository main
	sudo add-apt-repository universe
	sudo add-apt-repository restricted
	sudo add-apt-repository multiverse
	sudo apt-get update -y;
       	sudo apt-get upgrade -y;
		echo -e "${LYellow} Installing GIT${NC}"
       		sudo apt-get --assume-yes install git;
		echo -e "${LYellow} Installing Unzip${NC}"
        	sudo apt-get --assume-yes install unzip;
		echo -e "${LYellow} Installing Htop${NC}"
	        sudo apt-get --assume-yes install htop;
		echo -e "${LYellow} Installing JQ${NC}"
	        sudo apt-get --assume-yes install jq;
		echo -e "${LYellow} Installing Timeout${NC}"
		sudo apt-get --assume-yes install timeout;
		echo -e "${LYellow} Installing Lib build-sssemtial${NC}"
		sudo apt-get -y install build-essential;
		echo -e "${LYellow} Installing Lib libssl-dev${NC}"
		sudo apt-get -y install libssl-dev;
		echo -e "${LYellow} Installing Lib libdb++-dev${NC}"
		sudo apt-get -y install libdb++-dev;
		echo -e "${LYellow} Installing Lib libboost-all-dev${NC}"
		sudo apt-get -y install libboost-all-dev;
		echo -e "${LYellow} Installing Lib libqrencode-dev${NC}"
		sudo apt-get -y install libqrencode-dev;
		echo -e "${LYellow} Installing Lib libminiupnpc-dev${NC}"
		sudo apt-get -y install libminiupnpc-dev;
		echo -e "${LYellow} Installing Lib libgmp-dev${NC}"
		sudo apt-get -y install libgmp-dev;
		echo -e "${LYellow} Installing Lib libevent${NC}"
		sudo apt-get -y install libevent-dev;
		echo -e "${LYellow} Installing autogen${NC}"
		sudo apt-get -y install autogen;
		echo -e "${LYellow} Installing automake${NC}"
		sudo apt-get -y install automake;
		echo -e "${LYellow} Installing libtool${NC}"
		sudo apt-get -y install libtool;
	if [[ `lsb_release -rs` == "18.04" ]];
	then
		if [ ! -e openssl-1.0.1j.tar.gz ]
		then
			echo -e "${Blue} Ubuntu 18.04 Detected - Downgrading libssl-dev to make FS node work${NC}"
			sudo apt-get install make
			wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz
			tar -xzvf openssl-1.0.1j.tar.gz > /dev/null 2>&1;
			cd openssl-1.0.1j
			./config > /dev/null 2>&1;
			make depend
			make sudo
			make install
			sudo ln -sf /usr/local/ssl/bin/openssl `which openssl`
			cd ~
			openssl version -v
		else
			echo -e "${Blue} Downgraded libssl-dev detected - skipping process${NC}"
		fi
	 	#sudo apt-get update -y;
                sudo apt-get upgrade -y;
	fi
        echo -e "\n"
        echo -e "${LYellow} Done updating libraries and dependencies${NC}"
# Installing and preparing Firewall to D
echo -e "\n"
echo -e "${LYellow}\e[7m Setting Firewall                                                        \e[25m ${NC}"
        sudo ufw default deny incoming
        sudo ufw allow ssh/tcp
        sudo ufw limit ssh/tcp
        sudo ufw allow http/tcp
        sudo ufw allow https/tcp
        sudo ufw allow 9999/tcp
        sudo ufw logging on
        sudo ufw --force enable
        echo -e "\n"
        echo -e "${LYellow} Firwall settings done - rpc ports enabled                                ${NC}"
# Checks if a swapfile already exist, if not build one
echo -e "\n"
echo -e "${LYellow}\e[7m Configuring a swapfile of 2G if not present                             \e[25m ${NC}"
# size of swapfile in megabytes
swapsize=2048
# does the swap file already exist? if not build 1 of 2g
if [ ! -e /swapfile.img  ];
then
	echo -e "${LYellow}\e[7m Swapfile not found -  Adding 2G Swapfile                                \e[25m ${NC}"
	fallocate -l ${swapsize}M /swapfile.img
	chmod 600 /swapfile.img
	mkswap /swapfile.img
	swapon /swapfile.img
	echo '/swapfile.img	none	swap	sw	0 0' >> /etc/fstab
else
	echo -e "\n"
	echo -e "${LYellow} Swapfile found - No changes made                                         ${NC}"
fi
echo -e "\n"
# Installing Fail2ban
echo -e "${LYellow}\e[7m More Safety!                                                            \e[25m ${NC}"
        sudo apt-get install -y fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        sudo apt-get -y autoremove
        echo -e "\n"
        echo -e "${LYellow} Fail2ban installed succesfully                                           ${NC}"
# Last commands to build somedir to use later and print final output messages
echo -e "\n"
echo -e "${Green}\e[7m Vps updated and ready - Run dmanager again to install nodes             \e[25m ${NC}"
echo -e "\n"
echo -e "${Green} Building some directories to use installing nodes                       ${NC}"
	if [ ! -d "mkdir /var/lib/masternodes" ]
	then
		echo -ne $(mkdir /var/lib/masternodes > /dev/null 2>&1);
	fi
	if [ ! -d "mkdir /var/lib/masternodes/variants" ]
	then
		echo -ne $(mkdir /var/lib/masternodes/variants > /dev/null 2>&1);
	fi
	if [ ! -d "mkdir /etc/masternodes" ]
	then
		echo -ne $(mkdir /etc/masternodes > /dev/null 2>&1);
	fi
echo -e "\n"
echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord         \e[25m ${NC}"
		;;
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
2)
Green="\033[0;32m";
Red="\033[0;31m";
Yellow="\033[1;33m";
Blue="\033[1;34m";
LGreen="\e[92m";
LRed="\e[91m";
LYellow="\e[93m";
LBlue="\e[94m";
LMagenta="\e[95m";
NC="\033[0m";

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo -e "${Red}\e[7m Ctrl-C caught...performing clean up      \e[25m ${NC}"
	rm -rf /var/lib/masternode/*
	rm -rf /etc/masternodes/*
	rm -rf /usr/local/bin/denariusd
    echo -e "${Green}\e[7m Cleanup done                               \e[25m ${NC}"
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "${LGreen}\e[7m               U. 16.04: Compile and Add one or more FS nodes               \e[25m ${NC}"
echo -e "${Blue}                               CTRL-C to exit ${NC}"
echo -e "\n"
# Count how many FS nodes are already installed and ask how many more to add
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo -e "${LGreen} $ifs node(s) already installed - How many more nodes to add?                ${NC}"
read -t 10 input
if [[ $? -ne 0 ]]
then ((mfs=0)) && ((fsarr=0))
	echo -e "${Red}\e[7m No selection was made - nothing was added                                  \e[25m${NC}"
else ((mfs=input)) && ((fsarr=1))
	echo -e "${LGreen}\e[7m Adding $input FS Nodes                                                           \e[25m${NC}"
# Start the download of denarius repository if not present and check branch + updates
	echo -e "${Green}\e[7m Installing Denarius Wallet                                                  \e[25m${NC}"
		if [ ! -d ~/denarius ]
		then
			echo -e "${Blue} Downloading Denarius Git ${NC}"
			git clone https://github.com/carsenk/denarius;
		else
			echo -e "${Green}\e[7m Denarius Git already Present - Checking for Updates                         \e[25m${NC}"
		fi
	cd denarius
	git checkout v3.4
	git pull
	echo -e "${Green}\e[7m Downloded latest v3.4 Branch - Start Compiling                              \e[25m${NC}"
	# Start to compile the daemon using downgraded lib if u.18 detected
	cd src
        if [[ `lsb_release -rs` == "18.04" ]];
        then
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile      ${NC}"
		echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?                 ${NC}"
                	select yn in "Yes" "No"; do
                	case $yn in
                        	Yes )\
	                	make clean -f makefile.unix >/dev/null 2>&1;
        	        	make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
        	        	strip denariusd
        	        	sudo yes | cp -rf denariusd /usr/local/bin
        	        	echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                           \e[25m${NC}"
        	        	echo -e "${Green}\e[7m Copied to /usr/local/bin for ease of use                                    \e[25m${NC}"
        	        	echo -e "\n"
                        	break;;
                        	No )\
                        	echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
                        	exit;;
	                	esac
        	        	done
                else
                sudo yes | cp -rf denariusd /usr/local/bin
                echo -e "${LYellow}\e[7m Daemon already compiled skipping process                                    \e[25m${NC}"
                fi
	else
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?                 ${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
					make clean -f makefile.unix >/dev/null 2>&1;
				make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
				strip denariusd
				sudo yes | cp -rf denariusd /usr/local/bin
				echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                           \e[25m${NC}"
				echo -e "${Green}\e[7m Copied to /usr/local/bin for ease of use                                    \e[25m${NC}"
				echo -e "\n"
				break;;
				 No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
				exit;;
				esac
				done
		else
			sudo yes | cp -rf denariusd /usr/local/bin
			echo -e "${LYellow}\e[7m Daemon already compiled skipping process                                    \e[25m${NC}"
		fi
	fi
	cd ..
	echo -e "\n"
    # Checks and download Chaindata, store it for later use during node's datadir creation
	echo -e "${Green}\e[7m Checking if Chaindata is already present                                    \e[25m${NC}"
        if	[ -e ~/denarius/chaindata1701122.zip ]
        then
		echo -e "${LYellow}\e[7m Chaindata already present - proceding...                                    \e[25m${NC}"
		echo -e "\n"
        else
		echo -e "${Green}\e[7m Getting  a new Chaindata                                                    \e[25m${NC}"
		wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1701122.zip
		echo -e "${Green}\e[7m Chaindata Downloaded                                                        \e[25m${NC}"
		echo -e "\n"
	fi
    # Start main loop - Build Datadir, Create and populate config file for each FS nodes
	n=0
	np=$((ifs+32360))
	fsn=$((ifs+1))
	while [ $n -lt $mfs ]
	do
        echo -e "${Green}\e[7m Now Installing FS node Number $((fsn))                                             \e[25m${NC}"
	echo -e "${Green}\e[7m Create and Populate denarius$((fsn)).conf file - Unzip Chaindata                   \e[25m${NC}"
        cd ..
        mkdir /var/lib/masternodes/denarius$((fsn)) > /dev/null 2>&1;
        mkdir /etc/masternodes > /dev/null 2>&1;
        echo -e "\nserver=1 \nrpcuser=user \nrpcpassword=changethispassword \nrpcallowsip=127.0.0.1 \nrpcport=$((np))  \n \nlisten=1 \ndaemon=1 \nfortunastake=0 \nfortunastakeprivkey=XXX_enterYouPrivKeyHere_XXX " > /etc/masternodes/denarius$((fsn)).conf
        echo -e "\nport=9999 \n#bind=[IPv6]:9999 \n#externalip=Ipv6  \n \naddnode=denarius.host \naddnode=denarius.win \naddnode=denarius.pro \naddnode=triforce.black \n " >> /etc/masternodes/denarius$((fsn)).conf
	# Unzip the previouse downloaded Chaindata
	cd /var/lib/masternodes/denarius$((fsn))
    	unzip ~/denarius/chaindata1701122.zip
    # Update Firewall rules setting rpc port for the current node
	echo -e "${LYellow}\e[7m Opening firewall port for FS node $((fsn))                                         \e[25m${NC}"
	sudo ufw allow $((np))
	sudo ufw allow $((np))/tcp
	sudo ufw logging on
	sudo ufw --force enable
    	echo -e "${Green}\e[7m Done installing FS node number $((fsn))                                           \e[25m ${NC}"
    	echo -e "\n"
	echo -e "${LYellow}\e[7m Populate denarius$((fsn)).conf addnode= - with latest FS nodes from Coinexplorer  \e[25m ${NC}"
	echo -e "${Blue} Get Coinexplorer FS List ${NC}"
	wget https://www.coinexplorer.net/api/v1/D/masternode/list;
	cat list | jq '.result[0].addr' | tr -d "\""  >> fspeers.txt;
	cat list | jq '.result[1].addr' | tr -d "\""  >> fspeers.txt;
	cat list | jq '.result[2].addr' | tr -d "\""  >> fspeers.txt;
	echo -e "${Green} Adding nodes to denarius$((fsn)).conf - Done ${NC}"
	sed 's/^/addnode=/' fspeers.txt > addnode.txt;
	cat addnode.txt >> /etc/masternodes/denarius$((fsn)).conf;
	echo -e "\n"
	echo -e "${Blue} Cleaning up temp files - Done ${NC}"
	rm list
	rm fspeers.txt
	rm addnode.tx
	let n++
	let np++
	let fsn++
	done
fi
	# Prints outputs according to what done
	if [[ $fsarr -eq 0 ]]
	then
		echo -e "${Red}\e[7m $mfs FS Nodes were installed  - aborting                                     \e[25m ${NC}"
	else
		echo -e "${Green}\e[7m $mfs FS New Nodes installed succesfully - $((mfs+ifs)) available now                     \e[25m ${NC}"
		cd ~/denarius/src
		# Notes and commands to start - stop - and getinfos from nodes
        	echo -e "\n"
        	echo -e "${LYellow}\e[7m\e[5m                               Important note:                              \e[25m ${NC}"
        	echo -e "${LYellow}\e[7m      Every .conf file need to be edited and proper informations added      \e[25m ${NC}"
		# echo -e "\n"
	        echo -e "${LYellow}\e[7m               To edit .conf file use the following command:                \e[25m ${NC}"
        	echo -e "${LGreen} nano /etc/masternodes/denariusX.conf ${NC}"
		echo -e "${Red} Remember to change the X with the required node number: ...denarius1.conf  ${NC}"
		echo -e "${LYellow} Edit Lines: rpcpassword= & fortunastakeprivkey= ${NC}"
		echo -e "${LYellow} Add & Edit Lines: bind=[ipv6]:9999 & externalip=ipv6 if u are using IPv6${NC}"
        	echo -e "\n"
        	echo -e "${LBlue} To start any daemon use the following command:                             ${NC}"
        	echo -e " denariusd -daemon -pid=/var/lib/masternodes/denariusX/denarius.pid -conf=/etc/masternodes/denariusX.conf -datadir=/var/lib/masternodes/denariusX "
        	echo -e "${LBlue} To stop any daemon use the following command:                               ${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denariusX.conf stop "
        	echo -e "${LBlue} To get informations of any deamon use the following command:                ${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denariusX.conf getinfo "
        	echo -e "${LBlue} To check any FS's node status use the following command:                    ${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denariusX.conf fortunastake status "
		echo -e "${LBlue} To Tail debug.log use the following command:                             ${NC}"
                echo -e " tail -f /var/lib/masternodes/denariusX/debug.log "
		echo -e "${Red} Remember to change the X with the required node number: ...denarius1.conf  ${NC}"
	fi
echo -e "\n"
echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord             \e[25m${NC}"
		;;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
3)
# Set Colors & other Variabilities
Green="\033[0;32m";
Red="\033[0;31m";
Yellow="\033[1;33m";
Blue="\033[1;34m";
LGreen="\e[92m";
LYellow="\e[93m";
LBlue="\e[94m";
Magenta="\e[35m";
White="\e[97m";
NC="\033[0m";
# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
function trap_ctrlc ()
{
        # perform cleanup here
        clear
        echo -e "${Red} Ctrl-C caught...performing clean up ${NC}"
        echo -e "${Green}\e[7m Cleanup done                           \e[25m ${NC}";
        # exit shell script with error code 2 if omitted, shell script will continue execution
        exit 2
}
# initialise trap to call trap_ctrlc function when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "${Green}\e[7m Ubuntu 16.04: Updating denariusd to latest v3.4 branch              \e[25m ${NC}"
	if [ ! -d ~/denarius ];
	then
		git clone https://github.com/carsenk/denarius > /dev/null 2>&1;
	else
		echo -e "${LYellow}\e[7m denarius repository already Present - Checking for Updates          \e[25m ${NC}"
	fi
cd denarius
git checkout v3.4
git pull
echo -e "${Green}\e[7m Downloded latest v3.4 Branch - Start Compiling                      \e[25m ${NC}"
cd src
        if [[ `lsb_release -rs` == "18.04" ]];
        then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile      ${NC}"
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?                 ${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
				rm -rf denariusd > /dev/null 2>&1;
                                make clean -f makefile.unix >/dev/null 2>&1;
                                make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
                                strip denariusd
                                sudo yes | cp -rf denariusd /usr/local/bin
                                echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                           \e[25m${NC}"
                                echo -e "${Green}\e[7m Copied to /usr/local/bin for ease of use                                    \e[25m${NC}"
                                echo -e "\n"
                                break;;
                                No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
                                exit;;
                                esac
                                done
        else
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?                 ${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
				rm -rf denariusd > /dev/null 2>&1;
                                make clean -f makefile.unix > /dev/null 2>&1;
                                make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
                                strip denariusd
                                sudo yes | cp -rf denariusd /usr/local/bin
                                echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                           \e[25m${NC}"
                                echo -e "${Green}\e[7m Copied to /usr/local/bin for ease of use                                    \e[25m${NC}"
                                echo -e "\n"
                                break;;
                                 No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
                                exit;;
                                esac
                                done
        fi
echo -e "\n"
echo -e "${Green}\e[7m Stop and restart the deamons to use the latest version              \e[25m ${NC}"
echo -e "\n"
echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord    \e[25m ${NC}"
		;;
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
4)
# Set Colors & other Variabilities
Green="\033[0;32m";
Red="\033[0;31m";
Yellow="\033[1;33m";
Blue="\033[1;34m";
LGreen="\e[92m";
LYellow="\e[93m";
LBlue="\e[94m";
Magenta="\e[35m";
White="\e[97m";
NC="\033[0m";
# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
function trap_ctrlc ()
{
	# perform cleanup here
	clear
	echo -e "${Red} Ctrl-C caught...performing clean up ${NC}"
	echo -e $(rm -rf /var/lib/masternodes/variants/*.*) > /dev/null 2>&1;
	echo -e "${LGreen}\e[7m Cleanup done                           \e[25m ${NC}";
	# exit shell script with error code 2 if omitted, shell script will continue execution
	exit 2
}
# initialise trap to call trap_ctrlc function when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2
# Start first while cicle to loop the entire script every XXX ( 300 ) seconds
while :
do
# Set Variabilities - if moved out of this position the script will run blank
n=0;
x=30;
x2=60;
declare -a nodesarray=("" "" "" "" "" "" "" "");
# Clear shell & Checks the number of nodes to monitor and set
clear;
echo -e "\n";
echo -e "\e[7m${LBlue}!!!          D-Monitor           !!!\e[25m${NC}";
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l);
echo -e "${LGreen}       Controlling $ifs FS Nodes     ${NC}";
# Insert date and time
echo -e "${LYellow}\e[1m    $(date)          \e[21m${NC}  ";
echo -e "${LGreen}------------------------------------\r${NC}";
# Check if nodes are working - set/read array conditions - print outputs -  execute commands to stop & restart the daemon - check pids and write to tmp file
while [ $n -lt $ifs ];
do
	# Set variabiles
        daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))";
	# Checks for FS's nodes status, set array to '' or '1' and write outputs to storage files
        if      [  $(pgrep -f "${daemon}") ];
        then    nodesarray[$n]=''
                # If node stopped for any reason then restarted changing pid, replace the new pid on file, it avoids some useless node reboot
		pgrep -f "${daemon}" > /var/lib/masternodes/denarius$((n+1))/denarius.pid;
                pid=$(</var/lib/masternodes/denarius$((n+1))/denarius.pid);
                # Print Fs status and getinfo outputs to storage files
		if timeout 6 denariusd -conf=/etc/masternodes/denarius$((n+1)).conf fortunastake status > /var/lib/masternodes/variants/fs$((n+1))status.txt;
                then $(tm=1)
		fi
		echo -e "Pid=${Blue} $pid ${NC}"
		timeout 6 denariusd -conf=/etc/masternodes/denarius$((n+1)).conf getinfo > /var/lib/masternodes/variants/fs$((n+1))info.txt;
			# Check for "fortunastake started remotely" message presence, if false, then change nodesarray[$n] vaule to '1'
			# This prevent the "out of sync" of the node bug, since that status changes if the node goes 2-300 blocks behind the blockchain
			# Even if the daemon is running we need to be sure it to not go out of sync waiting for manuall fix
			if	[ ! -e $(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt) ];
			then	nodesarray[$n]='1';
				echo -e "${Red}\e[7m!!!   Sync problems detected   !!!\e[25m${NC}";
			fi;
        else	nodesarray[$n]='1';
        fi;
	# If the nodearray is set to '' all is working fine and just print reports of elapsed time and blocks count
	if      [ ${#nodesarray[$n]} -eq 0 ];
        then
                # According to storage files status, print out relative outputs
                if      $(grep -q "Unknown" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${Red}\e[7mFS$((n+1)) Node just started - wait for refresh\e[25m${NC}";
                echo -e "${Red}If status persist manually stop!${NC}";
                elif    [ ! -e $(grep -q "" /var/lib/masternodes/variants/fs$((n+1))status.txt) ];
                then
                echo -e "${Red}\e[7mFS$((n+1))Daemon lagging - Wait for refresh\e[25m${NC}";
                echo -e "${Red}If status persist manually stop!${NC}";
                elif    $(grep -q "sync in process" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LYellow}\e[7m!FS$((n+1)) Node in sync - Wait until done!\e[25m${NC}";
                elif    $(grep -q "unconfigured" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LYellow}\e[7m!FS$((n+1)) Node in sync - Wait until done!\e[25m${NC}";
                echo -e "${LYellow}!If the status persist after sync is${NC}";
                echo -e "${LYellow}done, edit - .conf - file and set   ${NC}";
                echo -e "${LYellow}fortustake=1 (default 0 to sync fast)${NC}";
                elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LGreen}\e[7m!!  Started FS$((n+1)) Node Now in Queue !!\e[25m${NC}";
                elif    $(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LGreen}\e[7m!!!  FS$((n+1)) Node Working Regularly  !!!\e[25m${NC}";
                fi;
	        echo -e "$(ps -p $pid -o lstart,etime)";
        	echo -e "$(grep "network_status" /var/lib/masternodes/variants/fs$((n+1))status.txt)";
        	echo -e "${LGreen}             $(grep "blocks" /var/lib/masternodes/variants/fs$((n+1))info.txt)${NC}";
        # Else if the nodearray is set to '1' something is not working, warning outputs then stop- wait- start- wait- checks- the node print more outputs
        else
		echo -ne "${Red}\e[7m!!FS$((n+1)) Node not Working - Rebooting!!\r\e[25m${NC}";
            	# Stop the daemon and wait for X seconds to try to restart
		denariusd -conf=/etc/masternodes/denarius$((n+1)).conf.stop > /dev/null 2>&1;
            	while [ $x -gt 0 ];
            	do
            	sleep 1
            	echo -ne "${Red} Stopping FS$((n+1)) $x sec(s) until done!\r${NC}"
            	x=$(( $x - 1 ))
            	done;
		# Start the daemon and give him time to link the network and be able to print out status outpus
            	denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1)) > /dev/null 2>&1;
            	while [ $x2 -gt 0 ];
            	do
            	sleep 1
            	echo -ne "${LYellow} Starting FS$((n+1)) $x2 sec(s) until done!\r${NC}"
            	x2=$(( $x2 - 1 ))
            	done;
			# Once again, check status and getinfo outputs and print to files
	                if timeout 6 denariusd -conf=/etc/masternodes/denarius$((n+1)).conf fortunastake status > /var/lib/masternodes/variants/fs$((n+1))status.txt;
        	        then $(tm=1)
                	fi
        		timeout 6 denariusd -conf=/etc/masternodes/denarius$((n+1)).conf getinfo > /var/lib/masternodes/variants/fs$((n+1))info.txt;
			# According to storage files status, print relative outputs
                        if      $(grep -q "Unknown" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                        then
                        echo -e "${Red}\e[7mFS$((n+1)) Node just started - wait for refresh\e[25m${NC}";
	                echo -e "${Red}If status persist manually stop!${NC}";
			elif	[ ! -e $(grep -q "" /var/lib/masternodes/variants/fs$((n+1))status.txt) ];
			then
			echo -e "${Red}\e[7mFS$((n+1))Daemon lagging - Wait for refresh\e[25m${NC}";
			echo -e "${Red}If status persist manually stop!${NC}";
			elif	$(grep -q "sync in process" /var/lib/masternodes/variants/fs$((n+1))status.txt);
		        then
			echo -e "${LYellow}\e[7m!FS$((n+1)) Node in sync - Wait until done!\e[25m${NC}";
			elif    $(grep -q "unconfigured" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LYellow}\e[7m!FS$((n+1)) Node in sync - Wait until done!\e[25m${NC}";
                       	echo -e "${LYellow}!If the status persist after sync is${NC}";
                       	echo -e "${LYellow}done, edit - .conf - file and set   ${NC}";
			echo -e "${LYellow}fortustake=1 (default 0 to sync fast)${NC}";
			elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LGreen}\e[7m!!  Started FS$((n+1)) Node Now in Queue !!\e[25m${NC}";
			elif	$(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LGreen}\e[7m!!!  FS$((n+1)) Node Working Regularly  !!!\e[25m${NC}";
			fi;
	# After restarting the node, replace the new pid on file to print the correct outputs
	pgrep -f "${daemon}" > /var/lib/masternodes/denarius$((n+1))/denarius.pid;
        pid=$(</var/lib/masternodes/denarius$((n+1))/denarius.pid);
        echo -e "$(ps -p $pid -o lstart,etime)";
        echo -e "$(grep "network_status" /var/lib/masternodes/variants/fs$((n+1))status.txt)";
        echo -e "${LGreen}             $(grep "blocks" /var/lib/masternodes/variants/fs$((n+1))info.txt)${NC}";
	fi;
	let n++
	done
echo -e "${LGreen}------------------------------------\r${NC}";
echo -e "${LYellow}   Press CTRL+C to exit D-Monitor  \r${NC}";
echo -e "${LGreen}  Thank you for using this script!  \r${NC}";
# setting a timer before close the main "while" cycle - change the $t value to rise or lower it (default = 5 min)
t=60
while [ $t -gt 0 ];
do
sleep 1
echo -ne "${LBlue} Refreshing D-Monitor in $((t)) sec(s)!\r${NC}";
t=$(( $t - 1 ))
done
# Closing the main while cycle.
sleep 2
done
	;;
esac
echo Selected $choice
