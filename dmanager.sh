#!/bin/bash

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

# Setting a menu interface ( still to study and improve the general outputs  )
TEMP=/tmp/answer$$
whiptail --title "[D] - Manager" --menu "          Ubuntu 16.04/18.04 Denarius's Nodes Manager :" 20 0 0\
					1 "Setup Vps and install dependancies"\
					2 "U. 16.04: Compile and Add - one or more FS nodes"\
					3 "U. 16.04: Update denariusd to latest v3.4 branch commits"\
					4 "U. 18.04: Compile and Add - one or more FS nodes"\
					5 "U. 18.04: Update denariusd to latest v3.4 branch commits"\
					6 "D-Monitor - Controll & Reboot FS Nodes" 2>$TEMP
choice=`cat $TEMP`
case $choice in
#Start to process the menu options
1)
Green="\033[0;32m";
Red="\033[0;31m";
Yellow="\033[1;33m";
Blue="\033[1;34m";
LGreen="\e[92m";
LYellow="\e[93m";
LBlue="\e[94m";
NC="\033[0m";
clear
echo -e "\n"
echo -e "\e[7m${LBlue}!!!                            D-Vps Installer                            !!!\e[25m${NC}";
echo -e "\n"
echo -e "${LGreen}\e[7m 1 - Setup VPS and install dependancies                                      \e[25m ${NC}"
echo -e "${LYellow}\e[7m Updating linux packages & dependencies                                     \e[25m ${NC}"
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get --assume-yes install git unzip build-essential libboost﻿-all-dev libqrencode-d﻿ev libminiupnpc-dev libssl-﻿dev libdb++﻿-de﻿v autogen automake libtool
# Installing and preparing Firewall to D
echo -e "${LYellow}\e[7m Setting Firewall                                                        \e[25m ${NC}"
        sudo ufw default deny incoming
        sudo ufw allow ssh/tcp
        sudo ufw limit ssh/tcp
        sudo ufw allow http/tcp
        sudo ufw allow https/tcp
        sudo ufw allow 9999/tcp
        sudo ufw logging on
        sudo ufw --force enable
# Checks if a swapfile already exist, if not build one
echo -e "${LYellow}\e[7m Configuring a swapfile of 5G if not present                             \e[25m ${NC}"
        # size of swapfile in megabytes
        swapsize=2048
        # does the swap file already exist? if not build 1 of 2g
        if [ ! -e $(grep -q "swapfile.img" /etc/fstab) ]; then
        echo -e "${LYellow}\e[7m Swapfile not found -  Adding 2G Swapfile                                   \e[25m ${NC}"
        fallocate -l ${swapsize}M /swapfile.img
        chmod 600 /swapfile.img
        mkswap /swapfile.img
        swapon /swapfile.img
        echo '/swapfile.img none swap sw 0 0' >> /etc/fstab
        else
        echo -e "${LYellow}\e[7m Swapfile found - No changes made                                        \e[25m ${NC}"
        fi
	echo -e "\n"
# Installing Fail2ban
echo -e "${LYellow}\e[7m More Safety!                                                            \e[25m ${NC}"
        sudo apt-get install -y fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        sudo apt-get -y autoremove
# Last commands to build somedir to use later and print final output messages
echo -e "${Green}\e[7m Vps updated and ready - Run dmanager again to install nodes             \e[25m ${NC}"
echo -e "${Green} Building some directories to use installing nodes                       ${NC}"
	if [ ! -d "mkdir /var/lib/masternodes" ]
	then echo -ne $(mkdir /var/lib/masternodes) &>/dev/null
	fi
	if [ ! -d "mkdir /var/lib/masternodes/variants" ]
	then echo -ne $(mkdir /var/lib/masternodes/variants) &>/dev/null
	fi
	if [ ! -d "mkdir /etc/masternodes" ]
	then echo -ne $(mkdir /etc/masternodes) &>/dev/null
	fi
echo -e "\n"
echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord         \e[25m ${NC}"
		;;
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

clear
echo -e "\n"
echo -e "${LGreen}\e[7m U. 16.04: Compile and Add one or more FS nodes                            \e[25m ${NC}"
echo -e "\n"
# Count how many FS nodes are already installed and ask how many more to add
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo -e "${LGreen} $ifs node(s) already installed - How many more nodes to add?                ${NC}"
read -t 10 input
if [[ $? -ne 0 ]]
then ((mfs=0)) && ((fsarr=0))
	echo -e "${Red}\e[7m No selection was made - nothing was added                                 \e[25m ${NC}"
else ((mfs=input)) && ((fsarr=1))
	echo -e "${LGreen}\e[7m Adding $input FS Nodes                                                         \e[25m ${NC}"
	# Just to be sure we have all up to date - checks again for vps upgrade to do
	echo -e "${LYellow}\e[7m Updating linux packages                                                   \e[25m ${NC}"
	sudo apt-get update -y && sudo apt-get upgrade -y
	sudo apt-get --assume-yes install git unzip build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libevent-dev autogen automake libtool  obfs4proxy libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools qt5-default
	# Starting installation of the wallet(s) and compilation of the daemon
	echo -e "${Green}\e[7m Installing Denarius Wallet                                                 \e[25m ${NC}"
		if [ ! -d ~/denarius ]
		then
		git clone https://github.com/carsenk/denarius </dev/null 2>&1;
		else
		echo -e "${Green}\e[7m Denarius Git already Present - Checking for Updats                 \e[25m ${NC}"
		fi
	cd denarius
	git checkout v3.4
	git pull
        echo -e "${Green}\e[7m Downloded latest v3.4 Branch - Start Compiling                             \e[25m ${NC}"
	cd src
	if      [ ! -e ~/denarius/src/denariusd ]
        then
	make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
        strip denariusd
        sudo yes | cp -rf denariusd /usr/local/bin
        echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                          \e[25m ${NC}"
        echo -e "${Green}\e[7m Copied to /usr/local/bin for ease of use                                   \e[25m ${NC}"
	echo -e "\n"
	else
	echo -e "${LYellow}\e[7m Daemon already compiled skipping process                                   \e[25m ${NC}"
	cd ..
	echo -e "\n"
        # Checks and download Chaindata, store it for later use during node's datadir creation
	echo -e "${Green}\e[7m Checking if Chaindata is already present                                   \e[25m ${NC}"
                	if 	[ -e ~/denarius/chaindata1701122.zip ]
                	then 	echo -e "${LYellow}\e[7m Chaindata already present - proceding...                                   \e[25m ${NC}"
				echo -e "\n"
                	else	echo -e "${Green}\e[7m Getting  a new Chaindata                           \e[25m ${NC}"
				wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1701122.zip
				echo -e "${Green}\e[7m Chaindata Downloaded                               \e[25m ${NC}"
				echo -e "\n"
			fi
        fi
	# Build Datadir, Create and populate config file for each FS nodes
	n=0
	np=$((ifs+32360))
	fsn=$((ifs+1))
	while [ $n -lt $mfs ]
	do
        echo -e "${Green}\e[7m Now Installing FS node Number $((fsn))                                            \e[25m ${NC}"
	echo -e "${Green}\e[7m Create and Populate denarius$((fsn)).conf file - Unzip Chaindata                  \e[25m ${NC}"
        cd ..
        mkdir /var/lib/masternodes/denarius$((fsn)) </dev/null 2>&1;
        mkdir /etc/masternodes </dev/null 2>&1;
        echo -e "\nserver=1 \nrpcuser=user \nrpcpassword=changethispassword \nrpcallowsip=127.0.0.1 \nrpcport=$((np)) \nlisten=1 \ndaemon=1 \nfortunastake=1 \nfortunastakeprivkey=enterYouPrivKeyHere " > /etc/masternodes/denarius$((fsn)).conf
        echo -e "\nport=9999 \nbind=WriteYourIPv4/IPv6:portHere \nexternalip=WriteYourIPv4/Ipv6Here \naddnode=denarius.host \naddnode=denarius.win \naddnode=denarius.pro \naddnode=triforce.black \n " >> /etc/masternodes/denarius$((fsn)).conf
	# Unzip the previouse downloaded Chaindata
	cd /var/lib/masternodes/denarius$((fsn))
        unzip ~/denarius/chaindata1701122.zip
        # Update Firewall rules setting rpc port for the current node
	echo -e "${LYellow}\e[7m Opening firewall port for FS node $((fsn))                                        \e[25m ${NC}"
	sudo ufw allow $((np))
	sudo ufw allow $((np))/tcp
	sudo ufw logging on
	sudo ufw --force enable
        echo -e "${Green}\e[7m Done installing FS node number $((fsn))                                           \e[25m ${NC}"
        echo -e "\n"
	let n++
	let np++
	let fsn++
        done
fi
	# Prints outputs accoring to what done
	if [[ $fsarr -eq 0 ]]
	then
	echo -e "${Red}\e[7m $mfs FS Nodes were installed  - aborting                                     \e[25m ${NC}"
	else
	echo -e "${Green}\e[7m $mfs FS New Nodes installed succesfully - $((mfs+ifs)) available now                     \e[25m ${NC}"
	cd ~/denarius/src
	# Notes and command to start - stop - and getinfos from nodes
        echo -e "\n"
        echo -e "${LYellow}\e[7m                               Important note:                              \e[25m ${NC}"
        echo -e "${LYellow}\e[7m      Every .conf file need to be edited and proper informations added      \e[25m ${NC}"
	# echo -e "\n"
        echo -e "${LYellow}\e[7m               To edit .conf file use the following command:                \e[25m ${NC}"
        echo -e "${LGreen} nano /etc/masternodes/denariusX.conf ${NC}"
	echo -e "${Red} Remember to change the X with the required node number: ...denarius1.conf  ${NC}"
	echo -e "${LYellow} Edit Lines: rpcpassword= & fortunastakeprivkey= ${NC}"
	echo -e "${LYellow} Edit Lines: bind= & externalip= ${NC}"
        echo -e "\n"
        echo -e "${LBlue}\e[7m To start any daemon use the following command:                             \e[25m ${NC}"
        echo -e " denariusd -daemon -pid=/var/lib/masternodes/denariusX/denarius.pid -conf=/etc/masternodes/denariusX.conf -datadir=/var/lib/masternodes/denariusX "
        echo -e "${LBlue}\e[7m To stop any daemon use the following command:                              \e[25m ${NC}"
        echo -e " denariusd -conf=/etc/masternodes/denariusX.conf stop "
        echo -e "${LBlue}\e[7m To get informations of any deamon use the following command:               \e[25m ${NC}"
        echo -e " denariusd -conf=/etc/masternodes/denariusX.conf getinfo "
        echo -e "${LBlue}\e[7m To check any FS's node status use the following command:                   \e[25m ${NC}"
        echo -e " denariusd -conf=/etc/masternodes/denariusX.conf fortunastake status "
	echo -e "${Red} Remember to change the X with the required node number: ...denarius1.conf  ${NC}"
	fi
echo -e "\n"
echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord            \e[25m ${NC}"
		;;
3)
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

	echo -e "${Green}\e[7m Ubuntu 16.04: Updating denariusd to latest v3.4 branch              \e[25m ${NC}"
	if [ ! -d "~/denarius" ]
	then
	git clone https://github.com/carsenk/denarius </dev/null 2>&1
	else
	echo -e "${LYellow}\e[7m denarius repository already Present - Checking for Updates          \e[25m ${NC}"
	fi
	cd denarius
	git checkout v3.4
	git pull
        echo -e "${Green}\e[7m Downloded latest v3.4 Branch - Start Compiling                      \e[25m ${NC}"
	cd src
	if [ ! -e ~/denarius/src/denariusd ]
        then
	make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
        strip denariusd
        sudo yes | cp -rf denariusd /usr/local/bin
        echo -e "${Green}\e[7m Done Compiling Denarius FS Daemon                                   \e[25m ${NC}"
        echo -e "${Green}\e[7m Stop and restart the deamons to use the latest version              \e[25m ${NC}"
	echo -e "\n"
	else
        rm- rf denariusd
	make clean -f makefile.unix
        make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
        strip denariusd
        sudo yes | cp -rf denariusd /usr/local/bin
        echo -e "${Green}\e[7m Done compiling denarius FS daemon                                   \e[25m ${NC}"
        echo -e "${Green}\e[7m Stop and restart every daemons to use the latest version            \e[25m ${NC}"
        echo -e "\n"
	fi
	echo -e "\n"
	echo -e "${LGreen}\e[7m Thank you for using this script, pls report bugs in D's Discord    \e[25m ${NC}"
		;;
4)
		;;
5)
		;;
6)
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
declare -a nodesarray=("" "" "" "" "" "" "" "");
# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
function trap_ctrlc ()
{
	# perform cleanup here
	clear
	echo -e "${Red} Ctrl-C caught...performing clean up ${NC}"
	echo -e $(rm -rf /var/lib/masternodes/variants/*.*) > /dev/null 2>&1;
	echo -e "${Green}\e[7m Cleanup done                           \e[25m ${NC}";
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
x2=150;
# Clear shell & Checks the number of nodes to monitor and set
clear;
echo -e "\n";
echo -e "\e[7m${LBlue}!!!          D-Monitor           !!!\e[25m${NC}";
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l);
echo -e "${LGreen}       Controlling $ifs FS Nodes     ${NC}";
# Insert date and time
echo -e "${LYellow}\e[1m    $(date)          \e[21m${NC}  ";
# Check if nodes are working - set/read array conditions - print outputs -  execute commands to stop & restart the daemon - check pids and write to tmp file
while [ $n -lt $ifs ];
do
	# Set variabiles
        daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))";

	# Checks for FS's nodes status, set array to '' or '1' and write outputs to storage files
        if      [  $(pgrep -f "${daemon}") ];
        then    nodesarray[$n]='';
                # If node stopped for any reason then restarted changing pid, replace the new pid on file, it avoids some useless node reboot
		pgrep -f "${daemon}" > /var/lib/masternodes/denarius$((n+1))/denarius.pid;
                pid=$(</var/lib/masternodes/denarius$((n+1))/denarius.pid);
                # Print Fs status and getinfo outputs to storage files
		denariusd -conf=/etc/masternodes/denarius$((n+1)).conf fortunastake status > /var/lib/masternodes/variants/fs$((n+1))status.txt;
                denariusd -conf=/etc/masternodes/denarius$((n+1)).conf getinfo > /var/lib/masternodes/variants/fs$((n+1))info.txt;
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
                then    echo -e "${Yellow}\e[7m!FS$((n+1)) Node in sync - Wait until done!\e[25m${NC}";
                elif    $(grep -q "unregistered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then    echo -e "${LYellow}\e[7m! Unregistered FS$((n+1))-Start from QT Wallet!\e[25m${NC}";
                elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then    echo -e "${LGreen}\e[7m!!  Started FS$((n+1)) Node Now in Queue !!\e[25m${NC}"9;
                elif    $(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then    echo -e "${LGreen}\e[7m!!!  FS$((n+1)) Node Working Regularly  !!!\e[25m${NC}";
                fi;
                echo -e "$(ps -p $pid -o lstart,etime)";
                echo -e " $(grep "network_status" /var/lib/masternodes/variants/fs$((n+1))status.txt)";
                echo -e "${LGreen}              $(grep "blocks" /var/lib/masternodes/variants/fs$((n+1))info.txt)${NC}";
        # Else if the nodearray is set to '1' something is not working, warning outputs then stop- wait- start- wait- checks- the node print more outputs
        else    echo -e "${Red}\e[7m!!FS$((n+1)) Node not Working - Rebooting!!\r\e[25m${NC}";
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
                echo -ne "${Yellow} Starting FS$((n+1)) $x2 sec(s) until done!\r${NC}"
                x2=$(( $x2 - 1 ))
                done;
			# Once again, check status and getinfo outputs and print to files
			denariusd -conf=/etc/masternodes/denarius$((n+1)).conf fortunastake status > /var/lib/masternodes/variants/fs$((n+1))status.txt;
        	        denariusd -conf=/etc/masternodes/denarius$((n+1)).conf getinfo > /var/lib/masternodes/variants/fs$((n+1))info.txt;
			# According to storage files status, print relative outputs
			if      $(grep -q "Unknown" /var/lib/masternodes/variants/fs$((n+1))status.txt);
	                then    echo -ne "${Red}\e[7m! FS$((n+1)) Node in sync - Wait untill done!\e[25m${NC}";
        	        elif    $(grep -q "unregistered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
        	        then    echo -ne "${LYellow}\e[7m! Unregistered FS$((n+1))-Start from QT Wallet!\e[25m${NC}";
        	        elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then    echo -ne "${LGreen}\e[7m!!  Started FS$((n+1)) Node Now in Queue !!\e[25m${NC}"9;
                	elif    $(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then    echo -ne "${Green}\e[7m!!!  FS$((n+1)) Node Working Regularly  !!!\e[25m${NC}";
                	fi;
	                # After restarting the node, replace the new pid on file to print the correct outputs
	                pgrep -f "${daemon}" > /var/lib/masternodes/denarius$((n+1))/denarius.pid;
        	        pid=$(</var/lib/masternodes/denarius$((n+1))/denarius.pid);
                	echo -e "$(ps -p $pid -o lstart,etime)";
                	echo -e " $(grep "network_status" /var/lib/masternodes/variants/fs$((n+1))status.txt)";
                	echo -e "${LGreen}              $(grep "blocks" /var/lib/masternodes/variants/fs$((n+1))info.txt)${NC}";
	fi;
let n++
done
echo -e "${LYellow}   Press CTRL+C to exit D-Monitor  \r${NC}";
echo -e "${LGreen}    ./dmanager.sh to enter menu!   \r${NC}";
	# setting a timer before close the main "while" cycle - change the $t value to rise or lower it (default = 5 min)
	t=60
	while [ $t -gt 0 ];
	do
	sleep 1
	echo -ne "${LBlue}  Refreshing D-Monitor in $((t)) sec(s)!\r${NC}";
	t=$(( $t - 1 ))
	done
# Closing the main while cycle.
sleep 2
done
		;;
esac
echo Selected $choice
