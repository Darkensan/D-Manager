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
regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

# Setting a menu interface ( still to study and improve the general outputs  )
TEMP=/tmp/answer$$
whiptail --fb --title "[D] - Manager" --menu "                   Ubuntu 16.04/18.04 Denarius's FS Node(s) Manager :" 21 0 0 \
							1 "D-Setup   - Prepare the Vps and install dependancies and utilities" \
							2 "D-Nodes   - Compile Deamon & Build Node(s) - Master or v3.4 - Branch Commits" \
							3 "D-Update  - Update denariusd with latest - Master or v3.4 - Branch Commits" \
                                                        4 "D-IPv4    - Setting up Network & .conf file(s) with a multi IPv4 scheme"\
                                                        5 "D-IPv6    - (U.16.04 only) Setting up Network & .conf file(s) with a multi IPv6 scheme"\
                                                        6 "D-Onion   - Coming soon or later - Populate .conf with onion scheme"\
                                                        7 "D-Start   - Start all installed FS nodes" \
                                                        8 "D-Stop    - Stops all installed FS nodes" \
      							9 "D-Keys    - Prompt for PrivKey - Populate denarius*X*.conf" \
							0 "D-Reset   - Reset selected FS Node back to latest chaindata blocks" 2>$TEMP
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
# Infobox explaining the process of option 1 that is about to begin

whiptail --title "D-Compile" --msgbox "This procedure will prepare the VPS to run D daemon(s) - installing and updating all the libraries and dependancies required. Compatible with U.16.04 & U.18.04." 12 78;

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
# Checks if a swapfile already exist, if not build one
echo -e "\n"
echo -e "${LYellow} - Configuring a swapfile of 2G if not present ${NC}"
# Size of swapfile in megabytes
swapsize=2048
if [ ! -e ~/swapfile.img  ];
then
	echo -e "${LYellow} - Swapfile not found -  Adding 2G Swapfile ${NC}"
	fallocate -l ${swapsize}M ~/swapfile.img
	chmod 600 ~/swapfile.img
	mkswap ~/swapfile.img
	swapon ~/swapfile.img
	echo '~/swapfile.img	none	swap	sw	0 0' >> /etc/fstab
else
	echo -e "\n"
	echo -e "${LYellow} - Swapfile found - No changes made ${NC}"
fi
echo -e "\n"
# Installing Fail2ban
echo -e "${LYellow} - More Safety! - Installing Fail2ban ${NC}"
        sudo apt-get install -y fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        echo -e "\n"
        echo -e "${LYellow} - Fail2ban installed succesfully ${NC}"
	# Cleaning a bit from useless stuff to free some space?
        sudo apt-get -y autoremove
# Last commands to build some dirs to use later and print finals output messages
echo -e "\n"
echo -e "${LYellow} - Building some directories to use installing nodes${NC}"
	[ -d /var/lib/masternodes/variants ] || mkdir -p /var/lib/masternodes/variants > /dev/null 2>&1;
	[ -d /etc/masternodes ] || mkdir -p /etc/masternodes > /dev/null 2>&1;
	echo -e "${LYellow}Done${NC}"
echo -e "\n"
echo -e "${Green} - Vps updated and ready ${NC}"
echo -e "\n"
echo -e "${LGreen} To compile denariusd daemon and install FS nodes run D-Manager once more ${NC}"
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
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
# Infobox explaining the process of option 2 that is about to begin
whiptail --title "D-Compile" --msgbox "This procedure will compile a daemon if not present, create and populate folder(s) and file(s) for the number of node(s) choosen. \n \nChaindata will be downloaded and unzipped into node folder(s) for a faster syncronization. \n \nDenarius*X*.conf files will be populated adding 25 random peers to each .conf file, aswell as adding rpcpassword, rpcport and ip. \n \nSo far: \n Automatization for 1 node in Ipv4 both u.16 and u.18 . \n Multi Ipv4 and IPv6 scheme compatible with u.16.04 only. \n Working on u.18.04 and onion scheme." 22 78 0
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
                        select yn in "Master/Origin" "v3.4_Dev_Commits";
                        do
                                case $yn in
                                Master/Origin )\
                                        git checkout master
                                        git pull
					echo -e "${Green} Downloded latest Master/Orinig release - Start Compiling ${NC}"
                                        break;;
                                v3.4_Dev_Commits )\
                                        git checkout v3.4
                                        git pull
					echo -e "${Green} Downloded latest v3.4 Branch Commits - Start Compiling ${NC}"
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
	if	[ -e ~/denarius/chaindata1799510.zip ]
	then
		echo -e "${LYellow} Chaindata already present - proceding... ${NC}"
		echo -e "\n"
	else
		echo -e "${LYellow} Chaindata not found - downloading a new archive ${NC}"
		wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1799510.zip
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
	unzip -u ~/denarius/chaindata1799510.zip

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
	echo -e "daemon=1 \nlisten=1 \ndebug=1" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\nbind=${ipv4}:9999 \nexternalip=${ipv4}" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\nfortunastake=0 \nfortunastakeprivkey=XXX_key_XXX" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\naddnode=denarius.host \naddnode=denarius.win \naddnode=denarius.pro \naddnode=triforce.black" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##############################" >> /etc/masternodes/denarius$((fsn)).conf
	echo -e "\n##### Random Peers List ###### \n" >> /etc/masternodes/denarius$((fsn)).conf
		# Get the nodes list from coinexplorer then eleborate the infos "catting" lines with addr and filtering it removing blanck spaces and onion addresses
		echo -e "${Blue} Get Coinexplorer FS List ${NC}"
		wget https://www.coinexplorer.net/api/v1/D/masternode/list;
		cat list | jq '.result[].addr' | tr -d "\""  >> list.txt;
		sed -i -e '/^$/d;/onion:9999$/d;s/^/addnode=/' list.txt;
		# Shuffle 25 random node out of the list and add them to denariusX.conf file, building nodes with randoms addnode= keep the network decentralized?? maybe it helps?
		shuf -n 25 list.txt >> /etc/masternodes/denarius$((fsn)).conf;
	# Print ending messages
	echo -e "${Green} Adding rpcpassword= to denarius$((fsn)).conf - Done ${NC}"
	echo -e "${Green} Adding IPv4 to denarius$((fsn)).conf - Done ${NC}"
	echo -e "${Green} Adding 25 random nodes to denarius$((fsn)).conf - Done ${NC}"
	echo -e "\n"
	echo -e "${Blue} Cleaning up temp files - Done ${NC}"
	echo -e "\n"
	rm list list.txt
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
# Infobox explaining the process of option 3 that is about to begin
whiptail --title "D-Update" --msgbox "This procedure will delete the old daemon and compile a new one with latest Master/Origin release or v3.4 commits. A prompt will ask wich Branch to update, and again ask for a confirmation before to start." 8 78;
clear
echo -e "\n"
echo -e "${Green} Ubuntu 16.04 / 18.04: Updating denariusd to latest Master/Origin or v3.4 branch commits ${NC}"
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
                        select yn in "Master/Origin" "v3.4/Branch";
                        do
                                case $yn in
                                Master/Origin )\
                                        git checkout master
                                        git pull
                                        echo -e "${Green} Downloded latest Master/Orinig release - Start Compiling ${NC}"
                                        break;;
                                v3.4/Branch )\
                                        git checkout v3.4
                                        git pull
                                        echo -e "${Green} Downloded latest v3.4 Branch Commits - Start Compiling ${NC}"
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

4)
# Infobox explaining the process of option 4 that is about to begin
whiptail --title "D-Keys" --msgbox "This procedure will prompt for the Vps Ipv4 FailoverIP addresses, starting from the first additional IP ( never count the default Vps IPv4 ). \n  \nAll the time a new FS Node(s) will be installed, run 'D-IPv4' again and paste all the FailoverIP once more. \n \nBe prepared with a list of all the IPv4, one for each FS Node(s) to configure." 16 78
clear
if [ -f /etc/network/interfaces.d/50-cloud-init.cfg ] || [ -f /etc/netplan/50-cloud-init.yaml ]
then
		# Start the procedure to edit Network interfaces .cfg and denarius*X*.conf files with the correct parameters
                echo -e "${LGreen}--------------------------------------------------------------------------------- ${NC}"
                sed -i '/auto ens3:.*/,$d' /etc/network/interfaces.d/50-cloud-init.cfg > /dev/null 2>&1;
		sed -i '/addresses:.*/,$d' /etc/netplan/50-cloud-init.yaml > /dev/null 2>&1;
                while [ $n -lt $ifs2 ]
                do
                        ipv4=$(whiptail --title " [D] - Ipv4 " --inputbox "Paste your FS Node $((n+2)) IPv4 address here:" 20 80 3>&1 1>&2 2>&3)
                        exitstatus=$?
                                if [ $exitstatus -eq 0 ]
                                then
				        if [[ `lsb_release -rs` == "16.04" ]]
        				then
						if [[ ! -f /etc/network/interfaces.d/50-cloud-init.bck ]]
        					then
						# Making backup of Network interfaces .cfg file
					        cp -rf /etc/network/interfaces.d/50-cloud-init.cfg /etc/network/interfaces.d/50-cloud-init.bck > /dev/null 2>&1;
        					echo -e "${LGreen}Backup Copy of /etc/network/interfaces.d/50-cloud-init.cfg created: .../50-cloud-init.bck ${NC}"
        					fi
                                        	echo -e "auto ens3:$n \niface ens3:$n inet static \naddress $ipv4  \nnetmask 255.255.255.255" >> /etc/network/interfaces.d/50-cloud-init.cfg
						sed -i -e "s/bind=.*/bind=$ipv4:9999/;s/externalip=.*/externalip=$ipv4/" /etc/masternodes/denarius$((n+2)).conf
				        elif [[ `lsb_release -rs` == "18.04" ]]
        				then
                                                if [[ ! -f /etc/netplan/50-cloud-init.yaml ]]
                                                then
                                                # Making backup of Netplan interfaces .yaml file
                                                cp -rf /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.bck > /dev/null 2>&1;
                                                echo -e "${LGreen}Backup Copy of /etc/netplan/50-cloud-init.yaml created: .../50-cloud-init.bck ${NC}"
						fi
						echo -e "            addresses: \n            - $ipv4/32" >> /etc/netplan/50-cloud-init.yaml
						sed -i -e "s/bind=.*/bind=$ipv4:9999/;s/externalip=.*/externalip=$ipv4/" /etc/masternodes/denarius$((n+2)).conf
					fi
                                        echo -e "\n"
                                        echo -e "${LYellow} FS Node $((n+2)) IPv4 configured - processing next one ${NC}"
                                        sleep 1s
                                        echo -e "\n"
                                else
					# Restoring backup copy to default .cgf / yaml .
					if [[ `lsb_release -rs` == "16.04" ]]
                                        then
	                                        cp -rf /etc/network/interfaces.d/50-cloud-init.bck /etc/network/interfaces.d/50-cloud-init.cfg > /dev/null 2>&1;
        	                                rm /etc/network/interfaces.d/50-cloud-init.bck  > /dev/null 2>&1;
                			elif [[ `lsb_release -rs` == "18.04" ]]
					then
                                                cp -rf /etc/netplan/50-cloud-init.bck /etc/netplan/50-cloud-init.yaml > /dev/null 2>&1;
                                                rm /etc/netplan/50-cloud-init.bck  > /dev/null 2>&1;
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
        	echo -e "${Red}\e[4m! It is suggested to reboot the Vps !  use: ' reboot now ' command ! ${NC}"
        	echo -e "\n"
else
        echo -e "\n"
        echo -e "${Red}--------------------------------------------------------------------------------- ${NC}"
        echo -e "\n"
        echo -e "${Red}!- D-Ipv4 not compatible with current Network system - !${NC}"
        echo -e "\n"
        echo -e "${Red}--------------------------------------------------------------------------------- ${NC}"
        echo -e "\n"
        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
        echo -e "\n"
fi
		;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

5)
# Infobox explaining the process of option 5 that is about to begin
clear
whiptail --title "D-IPv6" --msgbox "This procedure will prompt for the Vps Ipv6, set the network interfaces and populate the FS Node(s) .conf file(s). \n \nIt is mandatory to paste the IPv6 in his extended form: xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx . \n \nBackup copy of original network interface.cfg can be found in /etc/network/interfaces.d/*.bck. \n \nReboot the Vps after the procedure is complete: ' reboot now ' ." 16 78
if [ -f /etc/network/interfaces.d/50-cloud-init.cfg ]
then
                if [ ! -f /etc/network/interfaces.d/50-cloud-init.bck ]
                then
                        cp -rf /etc/network/interfaces.d/50-cloud-init.cfg /etc/network/interfaces.d/50-cloud-init.bck
                fi
        ipv6=$(whiptail --title "D-Ipv6" --inputbox "Paste your Vps IPv6 address here:" 20 80 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus -eq 0 ]
        then
		if [[ `lsb_release -rs` == "16.04" ]]
                then
			while [[ $ipv6 =~ $regex ]]
                	do
                        	sed -i '/inet6/,$d' /etc/network/interfaces.d/50-cloud-init.cfg > /dev/null 2>&1;
                        	echo -e "\niface ens3 inet6 static \n                           address $ipv6 \n                                netmask 64" >> /etc/network/interfaces.d/50-cloud-init.cfg;
                        	uipv6=$(sed 's/.\{10\}$//' <<< "$ipv6")
                        	        while [ $n -lt $ifs ]
                        	        do
                        	                fip=d$(printf "%02d" $((n+1)))
                        	                echo -e "                               up /sbin/ip -6 addr add dev ens3 $uipv6:$fip" >> /etc/network/interfaces.d/50-cloud-init.cfg;
                        	                sed -i -e "s/bind=.*/bind=[$uipv6:$fip]:9999/;s/externalip=.*/externalip=$uipv6:$fip/" /etc/masternodes/denarius$((n+1)).conf
                        	                echo -e "\n"
                        	                echo -e "${LYellow} FS Node $((n+1)) IPv6 configured - processing next one ${NC}"
                        	        let n++
                        	        done
                        	echo -e "\n"
                        	echo -e "${LGreen} IPv6 configuratione done for all FS Node(s) installed. ${NC}"
                        	echo -e "\n"
                        	echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        	systemctl restart networking > /dev/null 2>&1;
                        	echo -e "\n"
                        	echo -e "${Red}\e[4m!!!   Reboot the Vps now using: ' reboot now ' command    !!!${NC}"
                        	echo -e "\n"
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
        	elif [[ `lsb_release -rs` == "18.04" ]]
		then
	                echo -e "\n"
	                echo -e "${Red}--------------------------------------------------------------------------------- ${NC}"
        	        echo -e "\n"
        	        echo -e "${Red}!- D-Ipv6 not compatible with Ubuntu 18.04 system - !${NC}"
        	        echo -e "\n"
        	        echo -e "${Red}--------------------------------------------------------------------------------- ${NC}"
        	        echo -e "\n"
        	        echo -e "$(LGreen)! Coming soon !$(NC)"
        	        echo -e "\n"
		fi
	else
                echo -e "\n"
                echo -e "${LYellow} You chose Cancel - Manually edit network .cfg file ${NC}"
                echo -e "\n"
                echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                echo -e "\n"
        exit 0
        fi
else
        echo -e "Different Network interfaces - procede manually to setup the interfaces and edit FS Node(s) .conf file(s)"
        echo -e "\n"
        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
        echo -e "\n"
fi
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

6)
clear
# Infobox explaining the process of option 6 that is about to begin
echo -e "\n"
echo -e "D-Onion  - Configurator for oinion address(es) FS Node(s)"
echo -e "\n"
echo -e "${LGreen} Coming Soon ${NC}"
echo -e "\n"
echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
echo -e "\n"
                ;;

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

7)
# Infobox explaining the process of option 7 that is about to begin
whiptail --title "D-Start" --msgbox "This procedure will send a start command to the installed FS Node's daemon(s) within a 5 sec delay" 8 78
clear
echo -e "${LGreen} Detected $ifs FS Nodes - Starting sleeping daemons now ${NC}"
        # Start daemon(s) with 5 sec delay
        while [ $n -lt $ifs ]
        do
                daemon="denariusd -daemon -pid=/var/lib/masternodes/denarius$((n+1))/denarius.pid -conf=/etc/masternodes/denarius$((n+1)).conf -datadir=/var/lib/masternodes/denarius$((n+1))"
                if [  ! $(pgrep -f "${daemon}") ]
                then
                        echo "x" >> x
                        echo -e "\n"
                        echo -e "${LYellow} Starting FS Node $((n+1)) ${NC}"
                        eval  $daemon
                        sleep 5s
                else
                        echo "" >> x
                        echo -e ""
                        echo -e "${LYellow} FS Node $((n+1)) already running - processing next daemon ${NC}"
                        sleep 2
                fi
        let n++
        done
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

8)
# Infobox explaining the process of option 8 that is about to begin
whiptail --title "D-Stop" --msgbox "This procedure will send a Stop command to the installed FS Node's daemon(s) within a 5 sec delay" 8 78
clear
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
                        sleep 5s
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

9)
# Infobox explaining the process of option 9 that is about to begin
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

0)
# Infobox explaining the process of option 0 that is about to begin
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
        		rm -rf database txleveldb smsgDB peers.dat > /dev/null 2>&1;
        		echo -e "\n"
        		echo -e "${LYellow} Proceding unzipping latest chaindata... ${NC}"
        		echo -e "\n"
        		# Checks and download Chaindata, store it for later use during node's db resetting
        		echo -e "${LYellow} Checking if Chaindata is already present ${NC}"
        		echo -e "\n"
                		if      [ -e ~/denarius/chaindata1799510.zip ]
                                then
                                	echo -e "${LGreen} Chaindata already present - proceding... ${NC}"
                                	echo -e "\n"
                                else
                                	echo -e "${LYellow} Chaindata not found - downloading a new archive ${NC}"
                                	cd ~/denarius
                                	wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1799510.zip
                                	echo -e "${Green} Chaindata Downloaded - proceding... ${NC}"
                                	echo -e "\n"
                                	cd ~
                                fi
                        unzip -u ~/denarius/chaindata1799510.zip
                        sleep 1s
                        echo -e "\n"
                        echo -e "${LGreen} Reset for FS Node $r done.${NC}"
                        echo -e "\n"
                        echo -e "${LGreen} Thanks for using this script, pls report bugs in D's Discord ${NC}"
                        echo -e "\n"
                else
                        echo -e ""
                        echo -e "${LRed} Detected running process for FS Node $r - Stop running FS Node before reset. ${NC}"
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


esac
echo Selected $choice
