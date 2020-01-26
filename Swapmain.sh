#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#
# RUN THIS SCRIPT VIA: setupSwap.sh, THIS SCRIPT IS USED BY setupSwap.sh
# READ THE NOTES AND DISCLAIMER WITHIN setupSwap.sh BEFORE RUNNING!
#

#remove disable swap, remove it and remove entry from fstab
removeSwap() {
    echo "Will remove swap and backup fstab."
    echo ""

    #get the date time to help the scripts
    backupTime=$(date +%y-%m-%d--%H-%M-%S)

    #get the swapfile name
    swapSpace=$(swapon -s | tail -1 |  awk '{print $1}' | cut -d '/' -f 2)
    #debug: echo $swapSpace

    #turn off swapping
    swapoff /$swapSpace

    #make backup of fstab
    cp /etc/fstab /etc/fstab.$backupTime
    
    #remove swap space entry from fstab
    sed -i "/swap/d" /etc/fstab

    #remove swapfile
    rm -f "/$swapSpace"

    echo ""
    echo "--> Done"
    echo ""
}

#spinner by: https://www.shellscript.sh/tips/spinner/
setupSwapSpinner() {
  spinner="/|\\-/|\\-"
  while :
  do
    for i in `seq 0 7`
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 1
    done
  done
}


#identifies available ram, calculate swap file size and configure
createSwap() {
    echo "Will create a swap and setup fstab."
    echo ""

    #get available physical ram
    availMemMb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    #debug: echo $availMemMb
    
    #convert from kb to mb to gb
    gb=$(awk "BEGIN {print $availMemMb/1024/1204}")
    #debug: echo $gb
    
    #round the number to nearest gb
    gb=$(echo $gb | awk '{print ($0-int($0)<0.499)?int($0):int($0)+1}')
    #debug: echo $gb

    echo "-> Available Physical RAM: $gb Gb"
    echo ""
    if [ $gb -eq 0 ]; then
        echo "Something went wrong! Memory cannot be 0!"
        exit 1;
    fi

    if [ $gb -le 2 ]; then
        echo "   Memory is less than or equal to 2 Gb"
        let swapSizeGb=$gb*2
        echo "   -> Set swap size to $swapSizeGb Gb"
    fi
    if [ $gb -gt 2 -a $gb -lt 32 ]; then
        echo "   Memory is more than 2 Gb and less than to 32 Gb."
        let swapSizeGb=4+$gb-2
        echo "   -> Set swap size to $swapSizeGb Gb."
    fi
    if [ $gb -gt 32 ]; then
        echo "   Memory is more than or equal to 32 Gb."
        let swapSizeGb=$gb
        echo "   -> Set swap size to $swapSizeGb Gb."
    fi
    echo ""

    echo "Creating the swap file! This may take a few minutes."
    echo ""

    #implement swap file

    #start the spinner:
    setupSwapSpinner &
    
    #make a note of its Process ID (PID):
    SPIN_PID=$!
    
    #kill the spinner on any signal, including our own exit.
    trap "kill -9 $SPIN_PID" `seq 0 15`

    #convert gb to mb to avoid error: dd-memory-exhausted-by-input-buffer-of-size-bytes
    let mb=$gb*1024

    #create swap file on root system and set file size to mb variable
    echo "-> Create swap file."
    echo ""
    dd if=/dev/zero of=/swapfile bs=1M count=$mb

    #set read and write permissions
    echo "-> Set swap file permissions."
    echo ""
    chmod 600 /swapfile

    #create swap area
    echo "-> Create swap area."
    echo ""
    mkswap /swapfile

    #enable swap file for use
    echo "-> Turn on swap."
    echo ""
    swapon /swapfile

    echo ""

    #update the fstab
    if grep -q "swap" /etc/fstab; then
        echo "-> The fstab contains a swap entry."
        #do nothing
    else
        echo "-> The fstab does not contain a swap entry. Adding an entry."
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab    
    fi

    echo ""
    echo "--> Done"
    echo ""

    # exit 0
}

#the main function that is run by the calling script.
function setupSwapMain() {
    #check if swap is on
    isSwapOn=$(swapon -s | tail -1)

    if [[ "$isSwapOn" == "" ]]; then
        echo "No swap has been configured! Will create."
        echo ""

        createSwap
    else
        echo "Swap has been configured. Will remove and then re-create the swap."
        echo ""
        
        removeSwap
        createSwap
    fi

    echo "Setup swap complete! Check output to confirm everything is good."
    echo -e "\n"
    echo -e "${Green} - Vps updated and ready ${NC}"
    echo -e "\n"
    echo -e "${LGreen} - To compile denariusd daemon and install FS nodes run D-Manager once more ${NC}"
    echo -e "\n"
    echo -e "${LGreen} - Thanks for using this script, pls report bugs in D's Discord ${NC}"
    echo -e "\n"
}


