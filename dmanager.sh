#!/bin/bash
# Setting usefull variables - some will be writed again later inside the script, or part of it will not work
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
ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
ifs2=$((ifs-1))
n=0
np=$((ifs+32360))
fsn=$((ifs+1))
ipv4="$(wget http://ipecho.net/plain -O - -q ; echo)"
t=60
dossl="OpenSSL 1.0.1j 15 Oct 2014"
regex='^([0-9a-fA-F]{3,4}:){1,7}[0-9a-fA-F]{3,4}$'
net=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2a;getline}')

# Setting a menu interface ( still to study and improve the general outputs  )
TEMP=/tmp/answer$$
whiptail --fb --title "[D] - Manager" --menu "                   Ubuntu 16.04/18.04 Denarius's FS Node(s) Manager :" 21 0 0 \
							1  "D-Setup    - Prepare the Vps and install dependancies and utilities" \
							2  "D-Nodes    - Compile Deamon & Build Node(s) - Master or Dev - Branch Commits" \
							3  "D-Update   - Update denariusd with latest - Master or Dev - Branch Commits" \
							4  "D-Reset    - Reset selected FS Node back to latest chaindata blocks" \
                                                        5  "D-IPv4     - Setting up Network & .conf file(s) with a multi IPv4 scheme"\
                                                        6  "D-IPv6     - Setting up Network & .conf file(s) with a multi IPv6 scheme"\
      							7  "D-Keys     - Prompt for a PrivKey for each installed FS Node - Populate relative denarius*X*.conf" \
							8  "D-Tail     - Tail selected FS Node debug.log" \
							9  "D-Info     - Getinfo over the selected FS Node" \
							10 "D-Status   - Dispaly selected FS Node status"\
							11 "D-Start    - Start Selected FS nodes and replace 25 random peers in the .conf file" \
							12 "D-Stop     - Stops Selected FS nodes" \
                                                        13 "D-StartAll - Start all installed FS nodes and replace 25 random peers in the .conf files" \
                                                        14 "D-StopAll  - Stops all installed FS nodes" \
							15 "D-Peers    - Delete the peers.dat files from a chosen FS Node folder" 2>$TEMP
choice=`cat $TEMP`
case $choice in

#Start to process the menu options
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

1)
		# this function is called when Ctrl-C is sent
		function trap_ctrlc ()
		{
		    # perform cleanup here
		    echo -e "${Red} Ctrl-C caught...performing clean up${NC}"
		    [ ! -d ~/openssl-1.0.1j/  ] || rm -rf ~/openssl-1.0.1j/ > /dev/null 2>&1;
		    [ ! -d ~/openssl-1.0.1j.tar.gz  ] || rm -rf ~/openssl-1.0.1j.tar.gz > /dev/null 2>&1;
		    echo -e "${Green} Cleanup done${NC}"
		    # exit shell script with error code 2
		    # if omitted, shell script will continue execution
		    exit 2
		}
		# initialise trap to call trap_ctrlc function
		# when signal 2 (SIGINT) is received
		trap "trap_ctrlc" 2

# Infobox explaining D-Setup process that is about to begin
whiptail --title "D-Setup" --msgbox "This procedure will prepare the VPS to run D daemon(s) - installing and updating all the libraries and dependancies required. Compatible with U.16.04 & U.18.04." 12 78;
clear
echo -e "\n"
echo -e "${LBlue}${BK}!!!                          D-Vps Installer                           !!!${NC}";
echo -e "\n"
echo -e "${LYellow} Updating linux packages & dependencies${NC}"
	sudo add-apt-repository main
	sudo add-apt-repository universe
	sudo add-apt-repository restricted
	sudo add-apt-repository multiverse
	sudo apt-get update -y;
  	sudo apt-get upgrade -y;
	echo -e "${LYellow} - Installing GIT ${NC}"
	sudo apt-get --assume-yes install git;
	echo -e "${LYellow} - Installing Unzip ${NC}"
      	sudo apt-get --assume-yes install unzip;
	echo -e "${LYellow} - Installing Htop ${NC}"
        sudo apt-get --assume-yes install htop;
	echo -e "${LYellow} - Installing JQ ${NC}"
   	sudo apt-get --assume-yes install jq;
	echo -e "${LYellow} - Installing Timeout ${NC}"
	sudo apt-get --assume-yes install timeout;
	echo -e "${LYellow} - Installing Pwgen ${NC}"
        sudo apt-get --assume-yes install pwgen;
        echo -e "${LYellow} - Installing dialog ${NC}"
        sudo apt-get --assume-yes install dialog;
	echo -e "${LYellow} - Installing Lib build-sssemtial ${NC}"
	sudo apt-get -y install build-essential;
	echo -e "${LYellow} - Installing Lib libssl-dev ${NC}"
	sudo apt-get -y install libssl-dev;
	echo -e "${LYellow} - Installing Lib libdb++-dev ${NC}"
	sudo apt-get -y install libdb++-dev;
	echo -e "${LYellow} - Installing Lib libboost-all-dev ${NC}"
	sudo apt-get -y install libboost-all-dev;
	echo -e "${LYellow} - Installing Lib libqrencode-dev ${NC}"
	sudo apt-get -y install libqrencode-dev;
	echo -e "${LYellow} - Installing Lib libminiupnpc-dev ${NC}"
	sudo apt-get -y install libminiupnpc-dev;
	echo -e "${LYellow} - Installing Lib libgmp-dev ${NC}"
	sudo apt-get -y install libgmp-dev;
	echo -e "${LYellow} - Installing Lib libevent ${NC}"
	sudo apt-get -y install libevent-dev;
	echo -e "${LYellow} - Installing autogen ${NC}"
	sudo apt-get -y install autogen;
	echo -e "${LYellow} - Installing automake ${NC}"
	sudo apt-get -y install automake;
	echo -e "${LYellow} - Installing libtool ${NC}"
	sudo apt-get -y install libtool;
	echo -e "${LYellow} - Installing libcurl4-openssl-dev ${NC}"
	sudo apt-get -y install libcurl4-openssl-dev;
	echo -e "${LYellow} - Installing nginx ${NC}"
	sudo apt-get -y install nginx;
	# Check the for Ubuntu 18.04 then for downgraded lib, if not present download the zip and prepare the lib
	if [[ `lsb_release -rs` == "18.04" ]];
	then
		if [[ `openssl version -v` == $dossl ]]
                then
                        echo -e "${Blue} - Ubuntu 18.04 Downgraded libssl-dev detected - Skipping process ${NC}"
                else
			echo -e "${Blue} - Ubuntu 18.04 Detected - Downgrading libssl-dev to enable FS daemon compilation ${NC}"
			sudo apt-get install make
			wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz
			tar -xzvf ~/openssl-1.0.1j.tar.gz
			cd ~/openssl-1.0.1j
			./config > /dev/null 2>&1;
			make depend
			make sudo
			make install
			sudo ln -sf /usr/local/ssl/bin/openssl `which openssl`
			cd ..
			openssl version -v
			rm -rf openssl-1.0.1j.tar.gz ~/openssl-1.0.1j/
			sudo apt-get update -y;
			sudo apt-get upgrade -y;
		fi
	fi
echo -e "\n"
echo -e "${LYellow} - Done updating libraries and dependencies ${NC}"
# Installing and preparing Firewall to D
echo -e "\n"
echo -e "${LYellow} - Confirguring a Firewall ${NC}"
        sudo ufw default deny incoming
        sudo ufw allow ssh/tcp
        sudo ufw limit ssh/tcp
        sudo ufw allow http/tcp
        sudo ufw allow https/tcp
        sudo ufw allow 9999/tcp
        sudo ufw logging on
        sudo ufw --force enable
        echo -e "\n"
        echo -e "${LYellow} - Firewall settings done - D port open ${NC}"

# Installing Fail2ban
echo -e "\n"
echo -e "${LYellow} - More Safety! - Installing Fail2ban ${NC}"
        sudo apt-get install -y fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
echo -e "\n"
echo -e "${Green} - Fail2ban installed succesfully ${NC}"

# Cleaning a bit from useless stuff to free some space?
echo -e "\n"
echo -e "${LYellow} - Cleaning useless stuff ${NC}"
        sudo apt-get -y autoremove
echo -e "\n"
echo -e "${Green} - Done${NC}"

# Last commands to build some dirs to use later and print finals output messages
echo -e "\n"
echo -e "${LYellow} - Building some directories to use installing nodes${NC}"
        [ -d /var/lib/masternodes/variants ] || mkdir -p /var/lib/masternodes/variants > /dev/null 2>&1;
        [ -d /etc/masternodes ] || mkdir -p /etc/masternodes > /dev/null 2>&1;
echo -e "\n"
echo -e "${Green} - Done${NC}"

# ----------------------------------------------------------------------------
#
# This script will create swap file if the swap file does not exist.
# It will disable the swap file and re-create it if it does exist.
#
# Re-create the swap to adjust the size when you change AWS instance types.
#check permissions
#
# Note the following assumptions:
# - you have enough disk-space for the new swap
#   - less than 2 Gb RAM - swap size: 2x the amount of RAM
#   - more than 2 GB RAM, but less than 32 GB - swap size: 4 GB + (RAM – 2 GB)
#   - 32 GB of RAM or more - swap size: 1x the amount of RAM
# - you are running as root user
# - your swap file is called: swapfile
#
# ----------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo ""
    echo "This script must be run as root! Login as root, sudo or su."
    echo ""
    exit 1;
fi

#load code functions
source /root/D-Manager/Swapmain.sh

#setup permissions for functions
chmod 500 /root/D-Manager/Swapmain.sh

echo ""
echo "--------------------------------------------------------------------------"
echo "setupSwap - creates swap space on your server based on AWS guidelines"
echo "--------------------------------------------------------------------------"
echo ""
echo "This will remove an existing swap file and then create a new one. "
echo "Please read the disclaimer and review the code before proceeding."
echo ""

echo -n " ¿Do you want to proceed? (y/n): "; read proceed
if [ "$proceed" == "y" ]; then
    echo ""

    setupSwapMain

else

    echo "You chose to exit. Bye!"
    echo -e "\n"
    echo -e "${Green} - Vps updated and ready ${NC}"
    echo -e "\n"
    echo -e "${LGreen} - To compile denariusd daemon and install FS nodes run D-Manager once more ${NC}"
    echo -e "\n"
    echo -e "${LGreen} - Thanks for using this script, pls report bugs in D's Discord ${NC}"
    echo -e "\n"

fi

echo ""
echo "--------------------------------------------------------------------------"
echo ""

exit 1

		;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2)
	# this function is called when Ctrl-C is sent
	function trap_ctrlc ()
	{
		# perform cleanup here
		echo -e "${Red} Ctrl-C caught...performing clean up${NC}"
	    	# rm -rf /var/lib/masternodes/* /etc/masternodes/* /usr/local/bin/denariusd ~/list ~/list.txt > /dev/null 2>&1;
	    	echo -e "${Green} Cleanup done${NC}"
   		# exit shell script with error code 2
    		# if omitted, shell script will continue execution
    		exit 2
	}
	# initialise trap to call trap_ctrlc function
	# when signal 2 (SIGINT) is received
	trap "trap_ctrlc" 2

# Infobox explaining D-Nodes process that is about to begin
whiptail --title "D-Nodes" --msgbox "This procedure will compile a daemon if not present, create and populate folder(s) and file(s) for the number of node(s) choosen. \n \nChaindata will be downloaded and unzipped into node folder(s) for a faster syncronization. \n \nDenarius*X*.conf files will be populated adding 25 random peers to each .conf file, aswell as adding rpcpassword, rpcport and ip. \n \nSo far: \n Automatization for 1 node in Ipv4 both u.16 and u.18 . \n Multi Ipv4 and IPv6 scheme compatible with u.16.04 only. \n Working on u.18.04 and onion scheme." 22 78 0
clear
echo -e "\n"
echo -e "${LGreen}${BK}               U. 16.04: Compile and Add one or more FS nodes                ${NC}"
echo -e "${Blue}                               CTRL-C to exit ${NC}"
echo -e "\n"
# Count how many FS nodes are already installed and ask how many more to add
until [[ $input =~ ^[0-9] ]];
do
echo -e "${LGreen} Detected $ifs installed node(s) - How many more to add? ${NC}"
read input
done
if [[ $? -ne 0 ]] | [[ $input -eq 0 ]]
then ((mfs=0)) && ((fsarr=0))
	echo -e "${Red} No selection was made - nothing was added ${NC}"
else ((mfs=input)) && ((fsarr=1))
	echo -e "${LGreen} Adding $input FS Nodes ${NC}"
	# Start the download of denarius repository if not present and check branch + updates
	echo -e "${Green} Installing Denarius Wallet ${NC}"
	cd ~
		if [ ! -d ~/denarius ]
		then
			echo -e "${Blue} Downloading Denarius Git${NC}"
			git clone https://github.com/carsenk/denarius;
		else
			echo -e "${Green} Denarius Git already Present - Checking for Updates ${NC}"
		fi
        cd ~/denarius
        echo -e "${LYellow} Wich branch to install? ${NC}"
                        select yn in "Master/Origin" "Dev/v3.3.9.7";
                        do
                                case $yn in
                                Master/Origin )\
                                        git checkout master
                                        git pull
					echo -e "${Green} Downloded latest Master/Orinig release - Start Compiling ${NC}"
                                        break;;
                                Dev/v3.3.9.7 )\
                                        git checkout v3.3.9.7
                                        git pull
					echo -e "${Green} Downloded latest v3.3.9.7 Branch Commits - Start Compiling ${NC}"
                                        break;;
                                esac
                        done
	# Start to compile the daemon using downgraded lib if u.18 detected
	cd src
        if [[ `lsb_release -rs` == "18.04" ]];
        then
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile ${NC}"
		echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede? ${NC}"
                	select yn in "Yes" "No";
			do
                		case $yn in
                        	Yes )\
	                		make clean -f makefile.unix >/dev/null 2>&1;
        	        		make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
        	        		strip denariusd
        	        		sudo yes | cp -rf denariusd /usr/local/bin
        	        		echo -e "${Green} Done Compiling Denarius FS Daemon ${NC}"
        	        		echo -e "${Green} Copied to /usr/local/bin for ease of use ${NC}"
        	        		echo -e "\n"
                        		break;;
                        	No )\
                        		echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
                        		exit;;
	                	esac
        	        done
                else
                sudo yes | cp -rf denariusd /usr/local/bin
                echo -e "${LYellow} Daemon already compiled skipping process ${NC}"
                fi
	else
		if      [ ! -e ~/denarius/src/denariusd ]
		then
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede anyway? ${NC}"
                        select yn in "Yes" "No";
			do
                  		case $yn in
                                Yes )\
					make clean -f makefile.unix >/dev/null 2>&1;
					make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
					strip denariusd
					sudo yes | cp -rf denariusd /usr/local/bin
					echo -e "${Green} Done Compiling Denarius FS Daemon ${NC}"
					echo -e "${Green} Copied to /usr/local/bin for ease of use ${NC}"
					echo -e "\n"
					break;;
				 No )\
                                	echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon${NC}"
					exit;;
				esac
			done
		else
			sudo yes | cp -rf denariusd /usr/local/bin
			echo -e "${LYellow} Detected an already compiled daemon - skipping process ${NC}"
		fi
	fi
	cd ..
	echo -e "\n"

# Checks and download Chaindata, store it for later use during node's datadir creation
echo -e "${Green} Checking if Chaindata is already present ${NC}"
	if	[ -e ~/denarius/chaindata.zip ]
	then
		echo -e "${LYellow} Chaindata already present - proceding... ${NC}"
		echo -e "\n"
	else
		echo -e "${LYellow} Chaindata not found - downloading a new archive ${NC}"
		rm -rf ~/denarius/chaindata.zip
		wget https://chaindata.pos.watch/chaindata.zip
		echo -e "${Green} Chaindata Downloaded - proceding... ${NC}"
		echo -e "\n"
	fi

# Start main loop - Build Datadir, Create and populate config(s) file(s) for the installed FS node(s)s
while [ $n -lt $mfs ]
do
	echo -e "${Green} Installing FS node Number $((fsn)) ${NC}"
	echo -e "${Green} Create and Populate denarius$((fsn)).conf file - Unzip Chaindata ${NC}"
	cd ..
	[ -d /var/lib/masternodes/denarius$((fsn)) ] || mkdir -p /var/lib/masternodes/denarius$((fsn)) > /dev/null 2>&1;

	# Unzip the previouse downloaded Chaindata
	cd /var/lib/masternodes/denarius$((fsn))
	unzip -o ~/denarius/chaindata.zip -d /var/lib/masternodes/denarius$((fsn))

	# Update Firewall rules setting rpc port for the current node
	echo -e "${LYellow} Opening firewall port for FS node $((fsn)) ${NC}"
	sudo ufw allow $((np))
	sudo ufw allow $((np))/tcp
	sudo ufw logging on
	sudo ufw --force enable
	echo -e "${Green} Done installing FS node number $((fsn)) ${NC}"
	echo -e "\n"
	echo -e "${LYellow} Populate denarius$((fsn)).conf with 25 random addnode= rpc password and IPv4 ${NC}"

	# Generate a fancy denarius*X*.conf files and add a random password for the rpc user, the ipv4 of the vps, set Fortunastake=0 for a faster sync, add default peers
	pw=$(pwgen 32 1)
	echo -e "##############################" > /etc/masternodes/denarius$((fsn)).conf
	echo -e "\nserver=1 \ndaemon=1 \nrpcuser=denariusrpc \nrpcpassword=${pw} \nrpcallowsip=127.0.0.1 \nrpcport=$((np))" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "daemon=1 \nlisten=1 \ndebug=1 \nmaxorphanblocks=300 \blocknotify=/root/status.sh" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\nbind=${ipv4}:9999 \nexternalip=${ipv4}" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\nfortunastake=0 \nfortunastakeprivkey=XXX_key_XXX" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\naddnode=denarius.host \naddnode=denarius.win \naddnode=denarius.pro \naddnode=triforce.black" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n############################## \n" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\##### Random Peers List ###### \n" >> /etc/masternodes/denarius$((fsn)).conf
		# Get the nodes list from coinexplorer then eleborate the infos "catting" lines with addr and filtering it removing blanck spaces and onion addresses, black list 141. and 33. ip range.
		echo -e "${Blue} Get Coinexplorer FS List ${NC}"
		wget https://www.coinexplorer.net/api/v1/D/masternode/list;
		cat list | jq '.result[].addr' | tr -d "\""  >> list.txt;
		sed -i -e '/^$/d;/onion:9999$/d;/^141/d;/^33/d;s/^/addnode=/' list.txt;
		# Shuffle 25 random node out of the list and add them to denariusX.conf file, building nodes with randoms addnode= keep the network decentralized?? maybe it helps?
		shuf -n 25 list.txt >> /etc/masternodes/denarius$((fsn)).conf;
	# Print ending messages
	echo -e "${Green} Adding rpcpassword= to denarius$((fsn)).conf - Done ${NC}"
	echo -e "${Green} Adding IPv4 to denarius$((fsn)).conf - Done ${NC}"
	echo -e "${Green} Adding 25 random nodes to denarius$((fsn)).conf - Done ${NC}"
	echo -e "\n"
	echo -e "${Blue} Cleaning up temp files - Done ${NC}"
	echo -e "\n"
	rm -rf list list.*
	let n++
	let np++
	let fsn++
done
fi
	# Prints outputs according to what done
	if [[ $fsarr -eq 0 ]]
	then
		echo -e "${Red} $mfs FS Nodes were installed  - aborting ${NC}"
	else
		echo -e "${Green} $mfs FS New Nodes installed succesfully - $((mfs+ifs)) available now ${NC}"
		# Notes and Commands to start - stop - and getinfos from nodes
        	echo -e "\n"
		echo -e "${LYellow}----------------------------------------------------------------------------- ${NC}"
        	echo -e "${LYellow}${BK}                               Important note:                               ${NC}"
        	echo -e "${LYellow} !!!   Every .conf file need to be edited and proper informations added   !!! ${NC}"
        	echo -e "\n"
		        echo -e "${LGreen}       Use the following commands: ${NC}"
			echo -e "${LGreen} -------------------------------------- ${NC}"
			n=0
			ifs=$(ls /etc/masternodes/ | grep 'denarius.*\.conf' | wc -l)
			while [ $n -lt $ifs ]
			do
	       		echo -e "${LGreen}| nano /etc/masternodes/denarius$((n+1)).conf | ${NC}"
			let n++
			done
		echo -e "${LGreen} -------------------------------------- ${NC}"
		echo -e " Edit Line : ...privkey= to enter the node priv key or run D-Manager again."
		echo -e " Edit Lines: bind=[ipv6]:9999 & externalip=ipv6 if using an IPv6 scheme."
		echo -e " Edit Lines: bind=ipv4:9999 & externalip=ipv4 if using more then one FS node."
                echo -e "${LYellow}----------------------------------------------------------------------------- ${NC}"
        	echo -e "\n"
        	echo -e "${LBlue} To start a daemon use the following command: ${NC}"
        	echo -e " denariusd -daemon -pid=/var/lib/masternodes/denarius*X*/denarius.pid -conf=/etc/masternodes/denarius*X*.conf -datadir=/var/lib/masternodes/denarius*X* "
        	echo -e "${LBlue} To stop any daemon use the following command: ${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf stop "
        	echo -e "${LBlue} To get informations of any deamon use the following command: ${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf getinfo "
        	echo -e "${LBlue} To check any FS's node status use the following command:${NC}"
        	echo -e " denariusd -conf=/etc/masternodes/denarius*X*.conf fortunastake status "
		echo -e "${LBlue} To Tail debug.log use the following command: ${NC}"
                echo -e " tail -f /var/lib/masternodes/denarius*X*/debug.log "
		echo -e "${Red} Remember to change the *X* with the required node number: ...denarius1.conf"
	fi
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
		;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3)
	# This function is called when Ctrl-C is sent to close the D-Monitor script - deleting variants tmp file... more to add.
	function trap_ctrlc ()
	{
        	# perform cleanup here
        	clear
        	echo -e "${Red} Ctrl-C caught...performing clean up ${NC}"
        	rm -rf ~/denarius/ers/denariusd
		make clean -f makefile.unix >/dev/null 2>&1;
		echo -e "${Green} Cleanup done ${NC}";
        	# exit shell script with error code 2 if omitted, shell script will continue execution
        	exit 2
	}
        # initialise trap to call trap_ctrlc function when signal 2 (SIGINT) is received
        trap "trap_ctrlc" 2
# Infobox explaining D-Update process that is about to begin
whiptail --title "D-Update" --msgbox "This procedure will delete the old daemon and compile a new one with latest Master/Origin release or Dev/v3.3.9.7 commits. A prompt will ask wich Branch to update, and again ask for a confirmation before to start." 8 78;
clear
echo -e "\n"
echo -e "${Green} Ubuntu 16.04 / 18.04: Updating denariusd to latest Master/Origin or Dev/v3.3.9.7 branch commits ${NC}"
echo -e "${Blue}                                    CTRL-C to exit ${NC}"
echo -e "\n"
cd ~
        # check if denairus folder exist then download a new git repository
	if [ ! -d ~/denarius ];
        then
                git clone https://github.com/carsenk/denarius > /dev/null 2>&1;
        else
                echo -e "${LYellow} denarius repository already Present - Checking for Updates ${NC}"
        fi
	# ask wich branch to compile and start the process
        cd ~/denarius
        echo -e "${LYellow} Wich branch to install? ${NC}"
                        select yn in "Master/Origin" "Dev/v3.3.9.7";
                        do
                                case $yn in
                                Master/Origin )\
                                        git checkout master
                                        git pull
                                        echo -e "${Green} Downloded latest Master/Orinig release - Start Compiling ${NC}"
                                        break;;
                                Dev/v3.3.9.7 )\
                                        git checkout v3.3.9.7
                                        git pull
                                        echo -e "${Green} Downloded latest v3.3.9.7 Branch Commits - Start Compiling ${NC}"
                                        break;;
                                esac
                        done
cd src
	#check for u.18.04 release to decide if necessary to use a downgraded lib
        if [[ `lsb_release -rs` == "18.04" ]];
        then
                echo -e "${Blue} Ubuntu 18.04 Detected - Using downgraded libssl-dev path to compile ${NC}"
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede? ${NC}"
                        select yn in "Yes" "No";
                        do
                        case $yn in

                                Yes )\
                                        rm -rf denariusd > /dev/null 2>&1;
                                        make clean -f makefile.unix >/dev/null 2>&1;
                                        make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-" OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib;
                                        strip denariusd
                                        sudo yes | cp -rf denariusd /usr/local/bin
                                        echo -e "${Green} Done Compiling Denarius FS Daemon ${NC}"
                                        echo -e "${Green} Copied to /usr/local/bin for ease of use ${NC}"
                                        echo -e "\n"
                                        break;;
                                No )\
                                        echo -e "${Red} Aborting compilation  - Run the script again to update denariusd daemon ${NC}"
                                        exit;;
                                esac
                        done
        else
		# Complie deamon under u.16 build
                echo -e "${Yellow} Daemon compilation will take around 10~40 min - Procede? ${NC}"
                        select yn in "Yes" "No";
                        do
                        case $yn in
                                Yes )\
                                        rm -rf denariusd > /dev/null 2>&1;
                                        make clean -f makefile.unix > /dev/null 2>&1;
                                        make -f makefile.unix "USE_UPNP=-" "USE_NATIVETOR=-"
                                        strip denariusd
                                        sudo yes | cp -rf denariusd /usr/local/bin
                                        echo -e "${Green} Done Compiling Denarius FS Daemon ${NC}"
                                        echo -e "${Green} Copied to /usr/local/bin for ease of use ${NC}"
                                        echo -e "\n"
                                        break;;
                                 No )\
                                        echo -e "${Red} Aborting compilation  - Run the script again to build denariusd daemon ${NC}"
                                        exit;;
                                esac
                        done
        fi
cd ~
echo -e "\n"
echo -e "${Green} Stop and restart the deamons to use the latest version ${NC}"
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

5)
# Infobox explaining D-IPv4 process that is about to begin
whiptail --title "D-IPv4" --msgbox "This procedure will prompt for the Vps Ipv4 FailoverIP addresses, starting from the first additional IP ( never count the default Vps IPv4 ). \n  \nAll the time a new FS Node(s) will be installed, run 'D-IPv4' again and paste all the FailoverIP once more. \n \nBe prepared with a list of all the IPv4, one for each FS Node(s) to configure." 16 78
clear
# Checks for Network interface Name
if [[ `lsb_release -rs` == "16.04" ]]
then
	# Making backup of Network interfaces and preparing it for further population.
	if [[ ! -f /etc/network/interfaces.bck ]]
	then
        	cp -rf /etc/network/interfaces /etc/network/interfaces.bck > /dev/null 2>&1;
		echo -e "\n"
        	echo -e "${LYello}Backup Copy of /etc/network/interfaces created in /etc/network/interfaces.bck ${NC}"
		echo -e "\n"
	fi
	# Replace Interfaces file with 50-cloud-init-cfg, if the vps setup use that configuration
	if [[ -f /etc/network/interfaces.d/50-cloud-init.cfg ]]
	then
		cp -rf /etc/network/interfaces.d/50-cloud-init.cfg /etc/network/interfaces
		echo -e "iface$net inet6 auto \n" >> /etc/network/interfaces
	fi
	# Delete all previously added lines
        sed -i -r '/auto.*:.*/,${d}' /etc/network/interfaces > /dev/null 2>&1;
	sleep 2
elif [[ `lsb_release -rs` == "18.04" ]]
then
        echo -e "\n"
	cd /etc/netplan
	find . -type f -empty -delete
	cd ~
	for i in /etc/netplan/*.yaml
	do
		# Making backup of Netplan interfaces .yaml file
		if [[ ! -f $i.bck ]]
		then
		        cp -rf $i $i.bck > /dev/null 2>&1;
		fi
		# Delete all previously added lines
		sed -i '/addresses:.*/,$d' "$i" > /dev/null 2>&1;
		echo -e "${LYellow}Backup Copy of $i created in $i.bck ${NC}"
	done
	sleep 1
fi
	# Start the procedure to edit Network interfaces: clearing previouse adds and populating denarius*X*.conf files with the correct parameters
        while [ $n -lt $ifs2 ]
        do
        	ipv4=$(whiptail --title " [D] - Ipv4 " --inputbox "Paste your FS Node $((n+2)) IPv4 address here:" 20 80 3>&1 1>&2 2>&3)
        	exitstatus=$?
        		if [ $exitstatus -eq 0 ]
        		then
				if [[ `lsb_release -rs` == "16.04" ]]
				then
					echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
					sed -i -e "s/bind=.*/bind=$ipv4:9999/;s/externalip=.*/externalip=$ipv4/" /etc/masternodes/denarius$((n+2)).conf
        				echo -e "auto$net:$n \niface$net:$n inet static \naddress $ipv4  \nnetmask 255.255.255.255" >> /etc/network/interfaces
				elif [[ `lsb_release -rs` == "18.04" ]]
				then
					# Check all kind of .cfg file(s) (names can be different from providers to providers) and add the neccesary lines with correct spaces
					for i in /etc/netplan/*.yaml
					do
						sed -i -e '/^[[:blank:]]*$/d' $i
						tag0=$( tail -n 1 $i )
						tag1=$( expr match "$tag0" " *" )
						echo -e "addresses:\n- $ipv4/32" | { perl -pe "s/^/' 'x$tag1/e" ; } >> $i
					done
					sed -i -e "s/bind=.*/bind=$ipv4:9999/;s/externalip=.*/externalip=$ipv4/" /etc/masternodes/denarius$((n+2)).conf
				fi
        		echo -e "\n"
        		echo -e "${LYellow} FS Node $((n+2)) IPv4 configured - processing next one ${NC}"
        		echo -e "\n"
			echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
        		sleep 1s
        		echo -e "\n"
                    	else
				# Restoring backup copy to default .cgf / yaml .
				if [[ `lsb_release -rs` == "16.04" ]]
                                then
		                        cp -rf /etc/network/interfaces.bck /etc/network/interfaces > /dev/null 2>&1;
	        	                rm /etc/network/interfaces.bck  > /dev/null 2>&1;
                		elif [[ `lsb_release -rs` == "18.04" ]]
				then
                                	for i in /etc/netplan/*.yaml
					do
					cp -rf $i.bck $i > /dev/null 2>&1;
                                        rm $i.bck  > /dev/null 2>&1;
					done
				fi
		                echo -e "\n"
                	        echo -e "${LYellow} You chose Cancel - Manually edit network .cfg file ${NC}"
                                echo -e "\n"
                                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                                echo -e "\n"
                        exit 0
                        fi
	let n++
        done
# Resetting the Network to make the changes done in the configuration load
if [[ `lsb_release -rs` == "16.04" ]]
then
systemctl restart networking > /dev/null 2>&1;
elif [[ `lsb_release -rs` == "18.04" ]]
then
netplan --debug apply > /dev/null 2>&1;
fi
echo -e "${LYellow} Network Interfaces Edited ${NC}"
echo -e "\n"
echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
echo -e "\n"
echo -e "${LGreen} IPv4 configuration done for all installed FS Node(s). ${NC}"
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
		;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

6)
# Infobox explaining D-IPv6 process that is about to begin
whiptail --title "D-IPv6" --msgbox "This procedure will prompt for the Vps Ipv6, set the network interfaces and populate the FS Node(s) .conf file(s). \n \nIt is mandatory to paste the IPv6 in his extended form: \nxxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx \nWith all the ':0:' that  should be expanded as ':0000:'. \n \nBackup copy of original network interface.cfg can be found in /etc/network/interfaces.d/*.bck. " 16 78
clear
if [[ `lsb_release -rs` == "16.04" ]]
then
        # Making backup of Network interfaces .cfg file
        echo -e "\n"
        echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
        echo -e "\n"
        if [[ ! -f /etc/network/interfaces.bck ]]
        then
                cp -rf /etc/network/interfaces /etc/network/interfaces.bck > /dev/null 2>&1;
                echo -e "\n"
                echo -e "${LYello}Backup Copy of /etc/network/interfaces created in /etc/network/interfaces.bck ${NC}"
                echo -e "\n"
        fi
        # Replace Interfaces file with 50-cloud-init-cfg, if the vps setup use that configuration
        if [[ -f /etc/network/interfaces.d/50-cloud-init.cfg ]] || [[ -f /etc/network/interfaces.d/30-cloud-init.cfg ]]
        then
                cp -rf /etc/network/interfaces.d/50-cloud-init.cfg /etc/network/interfaces || cp -rf /etc/network/interfaces.d/30-cloud-init.cfg /etc/network/interfaces
        fi
       	sed -i '/^source/d' /etc/network/interfaces > /dev/null 2>&1;
	sed -i '/inet6/,$d' /etc/network/interfaces > /dev/null 2>&1;
	sleep 1
elif [[ `lsb_release -rs` == "18.04" ]]
then
	echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
        cd /etc/netplan
        find . -type f -empty -delete
        cd ~
        for i in /etc/netplan/*.yaml
        do
                # Making backup of Netplan interfaces .yaml file
                if [[ ! -f $i.bck ]]
                then
                        cp -rf $i $i.bck > /dev/null 2>&1;
                fi
	sed -i -r '/dhcp6:.*/d;/gateway6:.*/d;/addresses:.*/,$d' $i > /dev/null 2>&1;
	echo -e "${LYellow}Backup Copy of $i created in $i.bck ${NC}"
	sleep 1
	done
fi
# Start the procedure to edit Network interfaces cfg and denarius*X*.conf files with the correct parameters
ipv6=$(whiptail --title "D-Ipv6" --inputbox "Paste your Vps IPv6 address here:" 20 80 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus -eq 0 ]
then
	while [[ $ipv6 =~ $regex ]]
	do
               	if [[ `lsb_release -rs` == "16.04" ]]
	        then
                        l4ipv6=$(echo -n $ipv6 | tail -c 4)
                        uipv6=$(sed 's/.\{19\}$//' <<< "$ipv6")
                        uipv62="$uipv6:$l4ipv6"
                        tag0=$( tail -n 1 /etc/network/interfaces )
                        tag1=$( expr match "$tag0" " *" )
	               	echo -e "iface$net inet6 static \naddress $uipv62 \nnetmask 64" | { perl -pe "s/^/' 'x$tag1/e" ; } >> /etc/network/interfaces;
              	        while [ $n -lt $ifs ]
              	        do
              	                fip=d$(printf "%02d" $((n+1)))
	                        tag2=$( tail -n 1 /etc/network/interfaces )
	                        tag3=$( expr match "$tag2" " *" )
              	                echo -e "up /sbin/ip -6 addr add dev$net $uipv6:$fip" | { perl -pe "s/^/' 'x$tag3/e" ; } >> /etc/network/interfaces;
               	                sed -i -e "s/bind=.*/bind=[$uipv6:$fip]:9999/;s/externalip=.*/externalip=$uipv6:$fip/" /etc/masternodes/denarius$((n+1)).conf
               	                echo -e "\n"
               	                echo -e "${LYellow} FS Node $((n+1)) IPv6 configured - processing next one ${NC}"
				sleep 1
               	        let n++
               	        done
		        # Resetting the Network to make the changes done in the configuration load
       		        systemctl restart networking > /dev/null 2>&1;
                     	echo -e "\n"
                      	echo -e "${LGreen} IPv6 configuration done for all FS Node(s) installed. ${NC}"
                       	echo -e "\n"
			echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
                       	echo -e "\n"
                       	echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                       	echo -e "\n"
	        elif [[ `lsb_release -rs` == "18.04" ]]
        	then
			uipv6=$(sed 's/.\{19\}$//' <<< "$ipv6")
			l4ipv6=$(echo -n $ipv6 | tail -c 4)
			uipv62="$uipv6::$l4ipv6"
			for i in /etc/netplan/*.yaml
			do
				sed -i -e '/^[[:blank:]]*$/d' $i
				tag0=$( tail -n 1 $i )
				tag1=$( expr match "$tag0" " *" )
		                echo -e "dhcp6: false\ngateway6: $uipv6::1\naddresses:\n- $uipv62/64" | { perl -pe "s/^/' 'x$tag1/e" ; } >> $i
			done
				while [ $n -lt $ifs ]
                               	do
                                     	fip=d$(printf "%02d" $((n+1)))
					for i in /etc/netplan/*.yaml
					do
		                        	sed -i -e '/^[[:blank:]]*$/d' $i
        	                        	tag0=$( tail -n 1 $i )
	                                	tag1=$( expr match "$tag0" " *" )
						echo -e "- $uipv6::$fip/64" | { perl -pe "s/^/' 'x$tag1/e" ; } >> $i
                                      	done
					sed -i -e "s/bind=.*/bind=[$uipv6::$fip]:9999/;s/externalip=.*/externalip=$uipv6::$fip/" /etc/masternodes/denarius$((n+1)).conf
                                       	echo -e "\n"
                                       	echo -e "${LYellow} FS Node $((n+1)) IPv6 configured - processing next one ${NC}"
                                	sleep 1
				let n++
                                done
	        # Resetting the Network to make the changes done in the configuration load
		netplan --debug apply > /dev/null 2>&1;
		echo -e "\n"
                echo -e "${LGreen} IPv6 configuratione done for all FS Node(s) installed. ${NC}"
                echo -e "\n"
                echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
 		echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
               	fi
       	exit 0
       	done
        echo -e "\n"
        echo -e "${Red}! Warning wrong IPv6 format - Use the correct format: ! ${NC}"
        echo -e "\n"
        echo -e "${Red}        xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx ${NC}"
        echo -e "\n"
        echo -e "${Red}     Run D-Manager again and repeat the Procedure. ${NC}"
        echo -e "\n"
        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
        echo -e "\n"
else
        echo -e "\n"
        echo -e "${LYellow} You chose Cancel - Manually edit network .cfg file ${NC}"
        echo -e "\n"
        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
        echo -e "\n"
exit 0
fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

13)

                # this function is called when Ctrl-C is sent
                function trap_ctrlc ()
                {
                    # perform cleanup here
                    echo -e "${Red} Ctrl-C caught...performing clean up${NC}"
                    echo -e "${Green} Cleanup done${NC}"
                    # exit shell script with error code 2
                    # if omitted, shell script will continue execution
                    exit 2
                }
                # initialise trap to call trap_ctrlc function
                # when signal 2 (SIGINT) is received
                trap "trap_ctrlc" 2


# Infobox explaining D-StartAll process that is about to begin
whiptail --title "D-StartAll" --msgbox "This procedure will send a start command to the installed FS Node's daemon(s) within a 10 sec delay" 8 78
clear
echo -e "\n"
echo -e "${LGreen} Detected $ifs FS Nodes - Starting sleeping daemons now ${NC}"
        # Start daemon(s) with 5 sec delay
        while [ $n -lt $ifs ]
        do
                        echo -e "\n"
                        echo -e "${Blue} Replacing random peers with a new list ${NC}"
                        sed -i -e '/##### Random Peers List ######/,$d ' /etc/masternodes/denarius$((n+1)).conf;
                        # Get the nodes list from coinexplorer then eleborate the infos "catting" lines with addr and filtering it removing blanck spaces, onion addresses and 141. and 33. ip range
                        echo -e "\n"
			echo -e "${Blue} Get Coinexplorer's FS List if not present ${NC}"
			if [ ! -f list ];
		        then
				wget -4 https://www.coinexplorer.net/api/v1/D/masternode/list;
                        	cat list | jq '.result[].addr' | tr -d "\""  >> list.txt;
                        	sed -i -e '/^$/d;/onion:9999$/d;/^141/d;/^33/d;s/^/addnode=/' list.txt;
			else
				echo -e "${Yellow} peer list already present - processing next step ... ${NC}";
			fi
                        # Shuffle 25 random node out of the list and add them to denariusX.conf file, building nodes with randoms addnode= keep the network decentralized?? maybe it helps?
                        echo -e "${Blue} Shuffle random peers node into .conf file ${NC}"
                        echo -e "\n##### Random Peers List ###### \n" >> /etc/masternodes/denarius$((n+1)).conf
                        shuf -n 25 list.txt >> /etc/masternodes/denarius$((n+1)).conf;
                        echo -e "${LGreen} Done ${NC}"
                        echo -e "\n"
                echo -e "${Blue} Running the Daemon ${NC}"
                echo -e "\n"
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))"
                if [  ! $(pgrep -f "${daemon}") ]
                then
                        echo "x" >> x
                        echo -e "\n"
                        echo -e "${LYellow} Starting FS Node $((n+1)) ${NC}"
                        eval  $daemon
                        sleep 10s
                else
                        echo "" >> x
                        echo -e ""
                        echo -e "${LYellow} FS Node $((n+1)) already running - processing next daemon ${NC}"
                        sleep 2
                fi
        let n++
        done
rm -rf list.* list
xn=$(wc -w < x)
echo -e "\n"
echo -e "${LGreen} $((xn)) FS Nodes Started - give it some time to link blockchain ${NC}"
rm x > /dev/null 2>&1;
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
	     ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

14)
# Infobox explaining D-StopAll process that is about to begin
whiptail --title "D-StopAll" --msgbox "This procedure will send a Stop command to the installed FS Node's daemon(s) within a 10 sec delay" 8 78
clear
echo -e "\n"
echo -e "${Red} Detected $ifs FS Nodes - Stopping daemons now ${NC}"
        # Stop daemon(s) with 5 sec delay
        while [ $n -lt $ifs ]
        do
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))"
                if [  $(pgrep -f "${daemon}") ]
                then
                        echo "x" >> x
                        echo -e "\n"
                        echo -e "${LYellow} Stopping FS Node $((n+1)) ${NC}"
                        denariusd -conf=/etc/masternodes/denarius$((n+1)).conf stop
                        sleep 10s
                else
                        echo  "" >> x
                        echo -e ""
                        echo -e "${LYellow} FS Node $((n+1)) already sleeping - processing next daemon ${NC}"
                        sleep 2

                fi
        let n++
        done
xn=$(wc -w < x)
echo -e "\n"
echo -e "${Red} $((xn)) FS Nodes Stopped - give it some time before restart ${NC}"
rm x > /dev/null 2>&1;
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

7)
# Infobox explaining D-Keys process that is about to begin
whiptail --title "D-Keys" --msgbox "This procedure will prompt for a QT generated Private Key, then add the string to node(s) .conf file(s). Remember to use different Private Keys, one for each FS node(s) installed." 10 78
clear
echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
        while [ $n -lt $ifs ]
        do
        PK=$(whiptail --title " [D] - Manager " --inputbox "Paste the QT generated Private Key for FS Node $((n+1)) Here:" 8 60 3>&1 1>&2 2>&3)
        exitstatus=$?
                if [ $exitstatus -eq 0 ]
                then
                        sed -i "s/fortunastakeprivkey=.*/"fortunastakeprivkey=${PK}"/g" /etc/masternodes/denarius$((n+1)).conf
                        echo -e "${LGreen} Private Key for FS Node $((n+1)) :${NC}" "$PK  ${LGreen} | ${NC}"
                else
                        echo -e "${LGreen} You chose Cancel - Manually edit node's PrivKey into .conf file ${NC}"
                exit 0
                fi
        sed -i 's/fortunastake=0/fortunastake=1/g' /etc/masternodes/denarius$((n+1)).conf
        let n++
        done
echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
echo -e "${LGreen} Private Keys for $((ifs)) FS Nodes has been inserted into relative .conf file(s) ${NC}"
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

4)
# Infobox explaining D-Reset process that is about to begin
whiptail --title "D-Reset" --msgbox "This procedure will prompt for the FS Node number to reset, deleting cores files from his folder. \n \nDownload Latest Chaindata.zip, then unzip it for a faster sync into the correct FS Node folder." 10 78
clear
# Ask wich Node to reset
r=$(whiptail --title "D-Reset" --inputbox "Wich FS Node do you want to reset?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
	if [ $exitstatus -eq 0 ]
        then
        	daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
        	if [ ! $(pgrep -f "${daemon}") ]
        	then
        		echo -e "\n"
        		echo -e "${LYellow} Resetting FS Node $r DB ${NC}"
        		cd /var/lib/masternodes/denarius$r || exit
        		rm -rf database txleveldb smsgStore smsg.ini .lock i2pdebug.log debug.log db.log blk0001.dat denarius.pid peers.dat > /dev/null 2>&1;
        		echo -e "\n"
			echo -e "${Green} Done ${NC}"
			echo -e "\n"
        		# Checks and download Chaindata, store it for later use during node's db resetting
        		echo -e "${LYellow} Checking for latest zip archive... ${NC}"
        		echo -e "\n"
                		if      [ -e ~/denarius/chaindata.zip ]
                                then
                                	echo -e "${LGreen} Latest Chaindata already present - proceding unzipping... (may take a while)${NC}"
                                	echo -e "\n"
                                else
                                	echo -e "${LYellow} Chaindata not found - downloading a new zip archive ${NC}"
                                	cd ~/denarius
					rm -rf chaindata.* > /dev/null 2>&1;
                                	wget https://chaindata.pos.watch/chaindata.zip
                                	cd ~
					echo -e "${Green} Chaindata Downloaded - proceding... ${NC}"
                                	echo -e "\n"
                                fi
                        unzip -o ~/denarius/chaindata.zip -d /var/lib/masternodes/denarius$r > /dev/null 2>&1;
                        sleep 1s
                        echo -e "\n"
                        echo -e "${LGreen} FS Node $r reset done.${NC}"
                        echo -e "\n"
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e "\n"
                else
                        echo -e ""
                        echo -e "${LRed} FS Node $r running process detected - Stop FS Node daemon before the reset. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use: ' daemon="denariusd -conf=/etc/masternodes/denarius$r.conf stop" ' ${NC}"
                        echo -e ""
                        cd ~
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

8)
# Infobox explaining D-Tail process that is about to begin
whiptail --title "D-Tail" --msgbox "This procedure will prompt for the FS Node number to Tail, and start the command on shell. \nUse CTRL+C to exit the tailing the process. " 10 78
clear
# Ask wich Node to Tail.
r=$(whiptail --title "D-Tail" --inputbox "Wich FS Node do you want to Tail?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} About to tail FS Node $r debug.log ${NC}"
                        echo -e "\n"
                        tail -f /var/lib/masternodes/denarius$r/debug.log
                else
                        echo -e ""
                        echo -e "${LRed} Missing running process for FS Node $r - Nothing to Tail. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use D-Manager again to start the FS Node(s) ${NC}"
                        echo -e ""
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
	                echo -e "\n"
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

9)
# Infobox explaining D-Info process that is about to begin
whiptail --title "D-Info" --msgbox "This procedure will prompt for the FS Node number from wich to 'getinfo' out, and start the command on shell. " 10 78
clear
# Ask wich Node to Getinfo from.
r=$(whiptail --title "D-Info" --inputbox "Wich FS Node do you want to 'Getinfos'?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} About to 'Getinfo' from FS Node $r ${NC}"
                        echo -e "\n"
                        denariusd -conf=/etc/masternodes/denarius$r.conf getinfo
                	echo -e "\n"
			echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                	echo -e "\n"

                else
                        echo -e ""
                        echo -e "${LRed} Missing running process for FS Node $r - Nothing to 'Getinfo' from. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use D-Manager again to start the FS Node(s) ${NC}"
                        echo -e ""
			echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
	                echo -e ""
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

10)
# Infobox explaining D-Status process that is about to begin
whiptail --title "D-Status" --msgbox "This procedure will prompt for the FS Node number to dispaly the Status, and start the command on shell." 10 78
clear
# Ask wich Node Status to check.
r=$(whiptail --title "D-Status" --inputbox "Wich FS Node Status do you want to check?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} About to 'check the Status' of FS Node $r ${NC}"
                        echo -e "\n"
                        denariusd -conf=/etc/masternodes/denarius$r.conf fortunastake status
                        echo -e "\n"
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e "\n"

                else
                        echo -e ""
                        echo -e "${LRed} Missing running process for FS Node $r - No Status to check. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use D-Manager again to start the FS Node(s) and repeat the procedure again. ${NC}"
                        echo -e ""
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e ""
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

11)
# Infobox explaining D-Start process that is about to begin
whiptail --title "D-Start" --msgbox "This procedure will prompt for the FS Node number to start." 10 78
clear
# Ask wich Node to Start
r=$(whiptail --title "D-Start" --inputbox "Wich FS Node daemon do you want to run?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
	        daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ ! $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} About to 'Start' FS Node $r ${NC}"
                      	echo -e "\n"
                       	echo -e "${Blue} Relacing random peers with a new list ${NC}"
			sed -i -e '/##### Random Peers List ######/,$d ' /etc/masternodes/denarius$((r)).conf;
       	        	# Get the nodes list from coinexplorer then eleborate the infos "catting" lines with addr and filtering it removing blanck spaces and onion addresses
                      	echo -e "\n"
                	echo -e "${Blue} Get Coinexplorer FS List ${NC}"
               		wget -4 https://www.coinexplorer.net/api/v1/D/masternode/list;
               		cat list | jq '.result[].addr' | tr -d "\""  >> list.txt;
               		sed -i -e '/^$/d;/onion:9999$/d;/^141/d;/^33/d;s/^/addnode=/' list.txt;
               		# Shuffle 25 random node out of the list and add them to denariusX.conf file, building nodes with randoms addnode= keep the network decentralized?? maybe it helps?
			echo -e "${Blue} Shuffle random peers node into .conf file ${NC}"
		        echo -e "##### Random Peers List ###### \n" >> /etc/masternodes/denarius$((r)).conf
			shuf -n 25 list.txt >> /etc/masternodes/denarius$((r)).conf;
			rm -rf list.* list
			echo -e "${LGreen} Done ${NC}"
                       	echo -e "\n"
                       	echo -e "${Blue} Running the Daemon ${NC}"
                        eval $daemon
			sleep 3
                       	echo -e "\n"
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e "\n"

                else
                        echo -e ""
                        echo -e "${LRed} Detected running process for FS Node $r - Nothing to Strat. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use D-Manager again to stop the FS Node or choose a different one. ${NC}"
                        echo -e ""
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e ""
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

12)
# Infobox explaining D-Stop process that is about to begin
whiptail --title "D-Stop" --msgbox "This procedure will prompt for the FS Node number to Stop." 10 78
clear
# Ask wich Node to Stop
r=$(whiptail --title "D-Stop" --inputbox "Wich FS Node daemon do you want to Stop?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} About to 'Stop' FS Node $r ${NC}"
                        denariusd -conf=/etc/masternodes/denarius$r.conf stop
			sleep 2
                        echo -e "\n"
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e "\n"

                else
                        echo -e ""
                        echo -e "${LRed} No running process detected for FS Node $r - Nothing to Stop. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use D-Manager again to start the FS Node or choose a different one. ${NC}"
                        echo -e ""
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e ""
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

15)
# Infobox explaining D-Peers process that is about to begin
whiptail --title "D-Peers" --msgbox "This procedure will prompt for the FS Node number and delete the peers.dat files from his folder." 10 78
clear
# Ask wich Node peers.dat file to delete
r=$(whiptail --title "D-Peers" --inputbox "Wich FS Node peers.dat do you want to delete?" 10 78 3>&1 1>&2 2>&3)
exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$r/denarius.pid -conf=/etc/masternodes/denarius$r.conf -datadir=/var/lib/masternodes/denarius$r"
                if [ ! $(pgrep -f "${daemon}") ]
                then
                        echo -e "\n"
                        echo -e "${LYellow} Deleting FS Node $r peers.dat ${NC}"
                        cd /var/lib/masternodes/denarius$r || exit
                        rm -rf peers.dat > /dev/null 2>&1;
                        echo -e "\n"
                        echo -e "${Green} Done ${NC}"
                        echo -e "\n"
                else
                        echo -e ""
                        echo -e "${LRed} FS Node $r running process detected - Stop FS Node daemon before delete his peers.dat file. ${NC}"
                        echo -e ""
                        echo -e "${LRed} Use: ' daemon="denariusd -conf=/etc/masternodes/denarius$r.conf stop" ' ${NC}"
                        echo -e ""
                        cd ~
                exit 0
                fi
        else
                echo -e "\n"
                echo -e "${LYellow} No input or wrong input. Run the process again. ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

16)
#!/bin/bash
denariusd -conf=/etc/masternodes/denarius1.conf getblockcount > /var/www/html/block.txt
#stop and start installed FS Nodes
for ((i=1; i<7; i++))
do
echo "$i"
denariusd -conf=/etc/masternodes/denarius$i.conf fortunastake status > /var/www/html/$i.json
chmod -R 644 /var/www/html/*
done


		;;
#-------------------------------------------------------------------------------------------------------------------------------------------------------$
#-------------------------------------------------------------------------------------------------------------------------------------------------------$


esac
echo Selected $choice
