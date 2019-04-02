#!/bin/bash
# Setting a menu interface ( still to study and improve the general outputs  ) ~~~~~~~~~~~~~~~~~~~~   ~~ ~~ ~ ~~ ~ ~~ ~ ~~ ~ ~ ~
TEMP=/tmp/answer$$
whiptail --fb --title "[D] - Manager" --menu "      Ubuntu 16.04/18.04 Denarius's FS Nodes Manager :" 20 0 0\
					1 "D-Setup   - Prepare Vps and install dependancies"\
					2 "D-Compile - Add one or more FS nodes - v3.4 Branch"\
					3 "D-Update  - Build denariusd with latest v3.4 Branch commits"\
					4 "D-Keys    - Prompt for PrivKey - Populate denarius*X*.conf"\
					5 "D-Start   - Start all installed FS nodes"\
					6 "D-Stop    - Stops all installed FS nodes"\
					7 "D-Monitor - Control & Reboot FS Nodes while you sleep" 2>$TEMP
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
NC="\e[0m";
BK="\e[7m";

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo -e "${Red} Ctrl-C caught...performing clean up      ${NC}"
    echo -e "${Green} Cleanup done                                ${NC}"
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "${LBlue}!!!                          D-Vps Installer                           !!!${NC}";
echo -e "\n"
echo -e "${LGreen} 1 - Setup VPS and install dependancies                                   ${NC}"
echo -e "${LYellow} Updating linux packages & dependencies                                   ${NC}"
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
		echo -e "${LYellow} Installing Pwgen${NC}"
                sudo apt-get --assume-yes install pwgen;
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
	 	sudo apt-get update -y;
    sudo apt-get upgrade -y;
	fi
  echo -e "\n"
  echo -e "${LYellow} Done updating libraries and dependencies${NC}"
# Installing and preparing Firewall to D
echo -e "\n"
echo -e "${LYellow} Setting Firewall                                                         ${NC}"
        sudo ufw default deny incoming
        sudo ufw allow ssh/tcp
        sudo ufw limit ssh/tcp
        sudo ufw allow http/tcp
        sudo ufw allow https/tcp
        sudo ufw allow 9999/tcp
        sudo ufw logging on
        sudo ufw --force enable
        echo -e "\n"
        echo -e "${LYellow} Firwall settings done - rpc ports enabled${NC}"
# Checks if a swapfile already exist, if not build one
echo -e "\n"
echo -e "${LYellow} Configuring a swapfile of 2G if not present                              ${NC}"
# size of swapfile in megabytes
swapsize=2048
# does the swap file already exist? if not build 1 of 2g
if [ ! -e /swapfile.img  ];
then
	echo -e "${LYellow} Swapfile not found -  Adding 2G Swapfile                                 ${NC}"
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
echo -e "${LYellow} More Safety! - Installing Fail2ban                                       ${NC}"
        sudo apt-get install -y fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        sudo apt-get -y autoremove
        echo -e "\n"
        echo -e "${LYellow} Fail2ban installed succesfully                                           ${NC}"
# Last commands to build somedir to use later and print final output messages
echo -e "\n"
echo -e "${Green} Vps updated and ready - Run dmanager again to install nodes              ${NC}"
echo -e "\n"
echo -e "${Green} Building some directories to use installing nodes${NC}"
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
echo -e "${LGreen} To compile denariusd daemon and install FS nodes run D-Manager once more ${NC}"
echo -e "${LGreen} Thank you for using this script, pls report bugs in D's Discord          ${NC}"
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
NC="\e[0m";
BK="\e[7m";

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo -e "${Red} Ctrl-C caught...performing clean up       ${NC}"
	rm -rf /var/lib/masternode/*
	rm -rf /etc/masternodes/*
	rm -rf /usr/local/bin/denariusd
	rm list
	rm list.txt
    echo -e "${Green} Cleanup done                                ${NC}"
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "${LGreen}               U. 16.04: Compile and Add one or more FS nodes                ${NC}"
echo -e "${Blue}                               CTRL-C to exit ${NC}"
echo -e "\n"
# Count how many FS nodes are already installed and ask how many more to add
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo -e "${LGreen} $ifs node(s) already installed - How many more nodes to add?${NC}"
read -t 10 input
if [[ $? -ne 0 ]]
then ((mfs=0)) && ((fsarr=0))
	echo -e "${Red} No selection was made - nothing was added                                  ${NC}"
else ((mfs=input)) && ((fsarr=1))
	echo -e "${LGreen} Adding $input FS Nodes                                                           ${NC}"
# Start the download of denarius repository if not present and check branch + updates
	echo -e "${Green} Installing Denarius Wallet                                                  ${NC}"
		if [ ! -d ~/denarius ]
		then
			echo -e "${Blue} Downloading Denarius Git${NC}"
			git clone https://github.com/carsenk/denarius;
		else
			echo -e "${Green} Denarius Git already Present - Checking for Updates                         ${NC}"
		fi
	cd denarius
	git checkout v3.4
	git pull
	echo -e "${Green} Downloded latest v3.4 Branch - Start Compiling                              ${NC}"
	# Start to compile the daemon using downgraded lib if u.18 detected
	cd src
        if [[ `lsb_release -rs` == "18.04" ]];
        then
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile${NC}"
		echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?${NC}"
                	select yn in "Yes" "No"; do
                	case $yn in
                        	Yes )\
	                	make clean -f makefile.unix >/dev/null 2>&1;
        	        	make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
        	        	strip denariusd
        	        	sudo yes | cp -rf denariusd /usr/local/bin
        	        	echo -e "${Green} Done Compiling Denarius FS Daemon                                           ${NC}"
        	        	echo -e "${Green} Copied to /usr/local/bin for ease of use                                    ${NC}"
        	        	echo -e "\n"
                        	break;;
                        	No )\
                        	echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon${NC}"
                        	exit;;
	                	esac
        	        	done
                else
                sudo yes | cp -rf denariusd /usr/local/bin
                echo -e "${LYellow} Daemon already compiled skipping process                                    ${NC}"
                fi
	else
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
					make clean -f makefile.unix >/dev/null 2>&1;
				make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
				strip denariusd
				sudo yes | cp -rf denariusd /usr/local/bin
				echo -e "${Green} Done Compiling Denarius FS Daemon                                           ${NC}"
				echo -e "${Green} Copied to /usr/local/bin for ease of use                                    ${NC}"
				echo -e "\n"
				break;;
				 No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon${NC}"
				exit;;
				esac
				done
		else
			sudo yes | cp -rf denariusd /usr/local/bin
			echo -e "${LYellow} Daemon already compiled skipping process                                    ${NC}"
		fi
	fi
	cd ..
	echo -e "\n"
    # Checks and download Chaindata, store it for later use during node's datadir creation
	echo -e "${Green} Checking if Chaindata is already present                                    ${NC}"
        if	[ -e ~/denarius/chaindata1701122.zip ]
        then
		echo -e "${LYellow} Chaindata already present - proceding...                                    ${NC}"
		echo -e "\n"
        else
		echo -e "${Green} Getting  a new Chaindata                                                    ${NC}"
		wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1701122.zip
		echo -e "${Green} Chaindata Downloaded                                                        ${NC}"
		echo -e "\n"
	fi
    # Start main loop - Build Datadir, Create and populate config file for each FS nodes
	n=0
	np=$((ifs+32360))
	fsn=$((ifs+1))
	while [ $n -lt $mfs ]
	do
        echo -e "${Green} Now Installing FS node Number $((fsn))                                             ${NC}"
	echo -e "${Green} Create and Populate denarius$((fsn)).conf file - Unzip Chaindata                   ${NC}"
        cd ..
        mkdir /var/lib/masternodes/denarius$((fsn)) > /dev/null 2>&1;
        mkdir /etc/masternodes > /dev/null 2>&1;
	# Unzip the previouse downloaded Chaindata
	cd /var/lib/masternodes/denarius$((fsn))
    	unzip ~/denarius/chaindata1701122.zip
    # Update Firewall rules setting rpc port for the current node
	echo -e "${LYellow} Opening firewall port for FS node $((fsn))                                         ${NC}"
	sudo ufw allow $((np))
	sudo ufw allow $((np))/tcp
	sudo ufw logging on
	sudo ufw --force enable
    	echo -e "${Green} Done installing FS node number $((fsn))                                            ${NC}"
    	echo -e "\n"
	echo -e "${LYellow} Populate denarius$((fsn)).conf with 25 random addnode= rpc password and IPv4       ${NC}"
    # Generate a random password for the rpc user to add to .conf file
        pw=$(pwgen 32 1)
        ipv4="$(wget http://ipecho.net/plain -O - -q ; echo)"
	echo -e "server=1 \nrpcuser=denariusrpc \nrpcpassword=${pw} \nrpcallowsip=127.0.0.1 \nrpcport=$((np)) \nlisten=1 \ndaemon=1 \nfortunastake=0 \nfortunastakeprivkey=XXX_key_XXX" > /etc/masternodes/denarius$((fsn)).conf
        echo -e "\nbind=${ipv4}:9999 \nexternalip=${ipv4}\naddnode=denarius.host \naddnode=denarius.win \naddnode=denarius.pro \naddnode=triforce.black \n " >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "${Blue} Get Coinexplorer FS List${NC}"
    # Get the nodes list from coinexplorer then eleborate the infos "catting" lines with addr and filtering it removing blanck spaces and onion addresses
        wget https://www.coinexplorer.net/api/v1/D/masternode/list;
        cat list | jq '.result[].addr' | tr -d "\""  >> list.txt;
	sed -i -e '/^$/d;/onion:9999$/d;s/^/addnode=/' list.txt;
    # Shuffle 25 random node out of the list and add them to denariusX.conf file, building nodes with randoms addnod= keep the network decentralized?? maybe it helps?
        shuf -n 25 list.txt >> /etc/masternodes/denarius$((fsn)).conf;
        echo -e "${Green} Adding rpcpassword= to denarius$((fsn)).conf - Done${NC}"
        echo -e "${Green} Adding IPv4 to denarius$((fsn)).conf - Done${NC}"
        echo -e "${Green} Adding addnode= to denarius$((fsn)).conf - Done${NC}"
        echo -e "\n"
	echo -e "${Blue} Cleaning up temp files - Done${NC}"
	rm -rf list
	rm list.txt
	let n++
	let np++
	let fsn++
	done
fi
	# Prints outputs according to what done
	if [[ $fsarr -eq 0 ]]
	then
		echo -e "${Red} $mfs FS Nodes were installed  - aborting                                      ${NC}"
	else
		echo -e "${Green} $mfs FS New Nodes installed succesfully - $((mfs+ifs)) available now                      ${NC}"
		cd ~/denarius/src
		# Notes and commands to start - stop - and getinfos from nodes
        	echo -e "\n"
		echo -e "${LYellow}-----------------------------------------------------------------------------${NC}"
        	echo -e "${LYellow}\e[5m                               Important note:                               ${NC}"
        	echo -e "${LYellow} !!!   Every .conf file need to be edited and proper informations added   !!!${NC}"
	        echo -e "${LGreen}       Use the following commands:${NC}"
		n=0
		ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
		echo -e "${LGreen} -------------------------------------- ${NC}"
		while [ $n -lt $ifs ]
		do
	       	echo -e "${LGreen}| nano /etc/masternodes/denarius$((n+1)).conf |${NC}"
		let n++
		done
		# echo -e "${Red} Remember to change the *X* with the required node number: ...denarius1.conf \e[0m"
		echo -e "${LGreen} -------------------------------------- ${NC}"
		echo -e " Edit Line: fortunastakeprivkey= and enter the node priv key"
		echo -e " Edit Lines: bind=[ipv6]:9999 & externalip=ipv6 if using IPv6 scheme"
                echo -e "${LYellow}-----------------------------------------------------------------------------${NC}"
        	echo -e "\n"
        	echo -e "${LBlue} To start a daemon use the following command:${NC}"
        	echo -e " denariusd -daemon -pid=/var/lib/masternodes/denarius*X*/denarius.pid -conf=/etc/masternodes/denarius*X*.conf -datadir=/var/lib/masternodes/denarius*X* "
        	echo -e "${LBlue} To stop any daemon use the following command:${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf stop "
        	echo -e "${LBlue} To get informations of any deamon use the following command:${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf getinfo "
        	echo -e "${LBlue} To check any FS's node status use the following command:${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf fortunastake status "
		echo -e "${LBlue} To Tail debug.log use the following command:${NC}"
                echo -e " tail -f /var/lib/masternodes/denarius*X*/debug.log "
		echo -e "${Red} Remember to change the *X* with the required node number: ...denarius1.conf"
	fi
echo -e "\n"
echo -e "${LGreen} Thank you for using this script, pls report bugs in D's Discord             ${NC}"
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
NC="\e[0m";
BK="\e[7m";

# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
function trap_ctrlc ()
{
        # perform cleanup here
        clear
        echo -e "${Red} Ctrl-C caught...performing clean up${NC}"
        echo -e "${Green} Cleanup done                            ${NC}";
        # exit shell script with error code 2 if omitted, shell script will continue execution
        exit 2
}
# initialise trap to call trap_ctrlc function when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

clear
echo -e "\n"
echo -e "${Green} Ubuntu 16.04: Updating denariusd to latest v3.4 branch               ${NC}"
	if [ ! -d ~/denarius ];
	then
		git clone https://github.com/carsenk/denarius > /dev/null 2>&1;
	else
		echo -e "${LYellow} denarius repository already Present - Checking for Updates           ${NC}"
	fi
cd denarius
git checkout v3.4
git pull
echo -e "${Green} Downloded latest v3.4 Branch - Start Compiling                       ${NC}"
cd src
        if [[ `lsb_release -rs` == "18.04" ]];
        then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile${NC}"
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
				rm -rf denariusd > /dev/null 2>&1;
                                make clean -f makefile.unix >/dev/null 2>&1;
                                make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
                                strip denariusd
                                sudo yes | cp -rf denariusd /usr/local/bin
                                echo -e "${Green} Done Compiling Denarius FS Daemon                                           ${NC}"
                                echo -e "${Green} Copied to /usr/local/bin for ease of use                                    ${NC}"
                                echo -e "\n"
                                break;;
                                No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon${NC}"
                                exit;;
                                esac
                                done
        else
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede?${NC}"
                        select yn in "Yes" "No"; do
                        case $yn in
                                Yes )\
				rm -rf denariusd > /dev/null 2>&1;
                                make clean -f makefile.unix > /dev/null 2>&1;
                                make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
                                strip denariusd
                                sudo yes | cp -rf denariusd /usr/local/bin
                                echo -e "${Green} Done Compiling Denarius FS Daemon                                           ${NC}"
                                echo -e "${Green} Copied to /usr/local/bin for ease of use                                    ${NC}"
                                echo -e "\n"
                                break;;
                                 No )\
                                echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon${NC}"
                                exit;;
                                esac
                                done
        fi
echo -e "\n"
echo -e "${Green} Stop and restart the deamons to use the latest version               ${NC}"
echo -e "\n"
echo -e "${LGreen} Thank you for using this script, pls report bugs in D's Discord     ${NC}"
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
NC="\e[0m";
BK="\e[7m";
n=0
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
while [ $n -lt $ifs ]
do
PK=$(whiptail --title " [D] - Manager " --inputbox "Enter FSn $((n+1)) PrivKey here:" 8 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus -eq 0 ]
then
   sed -i "s/fortunastakeprivkey=.*/"fortunastakeprivkey=${PK}"/g" /etc/masternodes/denarius$((n+1)).conf
   echo "${LGreen}Private Key for FS Node $((n+1)):${NC}" $PK
else
   echo "{LYellow}You chose Cancel - Manually edit node's PrivKey into .conf file"
	exit 0
fi
sed -i 's/fortunastake=0/fortunastake=1/g' /etc/masternodes/denarius$((n+1)).conf
let n++
done
		;;
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
5)
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
NC="\e[0m";
BK="\e[7m";

n=0
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo -e "${LGreen}! Detected $ifs FS Nodes - Starting daemons now      !${NC}"
while [ $n -lt $ifs ]
do
denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))
echo -e "\n"
echo -e "${LGreen}! Starting FS Node $((n+1)) !${NC}"
sleep 5s
let n++
done
echo -e "\n"
echo -e "${LGreen}!$((ifs)) FS Nodes Started - give it some to link blockchain  !${NC}"
echo -e "${LGreen}!  Thanks for using this script!                    !${NC}"
		;;
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
NC="\e[0m";
BK="\e[7m";

n=0
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
echo -e "${Red}! Detected $ifs FS Nodes - Stopping daemons now        !${NC}"
while [ $n -lt $ifs ]
do
denariusd -conf=/etc/masternodes/denarius$((n+1)).conf stop
echo -e "${Red}! Stopping FS Node $((n+1)) !${NC}"
echo -e "\n"
sleep 3s
let n++
done
echo -e "\n"
echo -e "${Red}!$((ifs)) FS Nodes Stopped give it some time before restart!${NC}"
echo -e "${LGreen}!  Thanks for using this script!                    !${NC}"
		;;
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
7)
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
NC="\e[0m";
BK="\e[7m";

# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
function trap_ctrlc ()
{
	# perform cleanup here
	clear
	echo -e "${Red} Ctrl-C caught...performing clean up${NC}"
	echo -e $(rm -rf /var/lib/masternodes/variants/*.*) > /dev/null 2>&1;
	echo -e "${LGreen} Cleanup done                            ${NC}";
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
echo -e "${LBlue}!!!          D-Monitor           !!!${NC}";
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l);
echo -e "${LGreen}       Controlling $ifs FS Nodes${NC}";
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
				echo -e "${Red}!!!   Sync problems detected   !!!${NC}";
			fi;
        else	nodesarray[$n]='1';
        fi;
	# If the nodearray is set to '' all is working fine and just print reports of elapsed time and blocks count
	if      [ ${#nodesarray[$n]} -eq 0 ];
        then
                # According to storage files status, print out relative outputs
                if      $(grep -q "Unknown" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${Red}FS$((n+1)) Node just started - wait for refresh${NC}";
                echo -e "${Red}If status persist manually stop!${NC}";
                elif    [ ! -e $(grep -q "" /var/lib/masternodes/variants/fs$((n+1))status.txt) ];
                then
                echo -e "${Red}FS$((n+1))Daemon lagging - Wait for refresh${NC}";
                echo -e "${Red}If status persist manually stop!${NC}";
                elif    $(grep -q "sync in process" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LYellow}!FS$((n+1)) Node in sync - Wait until done!${NC}";
                elif    $(grep -q "unconfigured" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LYellow}!FS$((n+1)) Node in sync - Wait until done!${NC}";
                echo -e "${LYellow}!If the status persist after sync is${NC}";
                echo -e "${LYellow}done, edit - .conf - file and set${NC}";
                echo -e "${LYellow}fortustake=1 (default 0 to sync fast)${NC}";
                elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LGreen}!!  Started FS$((n+1)) Node Now in Queue !!${NC}";
                elif    $(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                then
                echo -e "${LGreen}!!!  FS$((n+1)) Node Working Regularly  !!!${NC}";
                fi;
	        echo -e "$(ps -p $pid -o lstart,etime)";
        	echo -e "$(grep "network_status" /var/lib/masternodes/variants/fs$((n+1))status.txt)";
        	echo -e "${LGreen}             $(grep "blocks" /var/lib/masternodes/variants/fs$((n+1))info.txt)${NC}";
        # Else if the nodearray is set to '1' something is not working, warning outputs then stop- wait- start- wait- checks- the node print more outputs
        else
		echo -e "${Red}!!FS$((n+1)) Node not Working - Rebooting!!\r${NC}";
            	# Stop the daemon and wait for X seconds to try to restart
		denariusd -conf=/etc/masternodes/denarius$((n+1)).conf stop > /dev/null 2>&1;
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
                        echo -e "${Red}FS$((n+1)) Node just started - wait for refresh${NC}";
	                echo -e "${Red}If status persist manually stop!${NC}";
			elif	[ ! -e $(grep -q "" /var/lib/masternodes/variants/fs$((n+1))status.txt) ];
			then
			echo -e "${Red}FS$((n+1))Daemon lagging - Wait for refresh${NC}";
			echo -e "${Red}If status persist manually stop!${NC}";
			elif	$(grep -q "sync in process" /var/lib/masternodes/variants/fs$((n+1))status.txt);
		        then
			echo -e "${LYellow}!FS$((n+1)) Node in sync - Wait until done!${NC}";
			elif    $(grep -q "unconfigured" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LYellow}!FS$((n+1)) Node in sync - Wait until done!${NC}";
                       	echo -e "${LYellow} When finish to sync edit denarius$((fsn)).conf!${NC}";
			echo -e "${LYellow} Set "fortunastake=1" (default 0 to sync faster)${NC}";
			elif    $(grep -q "registered" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LGreen}!!  Started FS$((n+1)) Node Now in Queue !!${NC}";
			elif	$(grep -q "fortunastake started remotely" /var/lib/masternodes/variants/fs$((n+1))status.txt);
                	then
			echo -e "${LGreen}!!!  FS$((n+1)) Node Working Regularly  !!!${NC}";
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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
esac
echo Selected $choice
