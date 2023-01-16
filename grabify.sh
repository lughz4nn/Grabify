#!/bin/bash
#BY: lughz4nn

# HOW WORKS?: With the code
# IF THE LINK IS https://grabify.link/ABCDEF -> <ABCDEF> is the code
# SO, <ABCDEF> you have to enter it


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"

#CHECK IF THE SYSTEM IS LINUX
if [ ! -d "$HOME/.termux" ]; then

    if [[ $EUID -ne 0 ]]; then
        echo -e "\nError, execute the script as root\n" 
        exit 1
    fi

    echo -e "\n${blueColour}Starting VPN..."

    #START THE JAPON VPN
    sudo openvpn --config .vpn/japonvpn.ovpn --auth-user-pass .vpn/credentials.txt --daemon

    stat=1

    sleep 5

else
    stat=0
fi


trap ctrl_c INT

function ctrl_c(){
    echo -e "\n\n${redColour}Exiting...${endColour}"
    if [ $stat -eq 1 ]; then
        ps aux | grep "openvpn --config" | grep "root" | head -n -1 | awk '{print $2}' | xargs sudo kill
    fi
    exit 0
}


function check(){

    clear

    echo ""

    #CHECK INTERNET CONEXION
    timeout 3 bash -c "ping -c 1 google.com > /dev/null 2>&1"
    if [ $(echo $?) != 0 ]; then
        echo -e "\n${redColour}No internet conexion${endColour}\n"
        exit 1
    fi

    #IP DANGER
    curl -s ip-api.com -o .ip-data

    echo -e "${yellowColour}This program hidde your IP IF YOU USE KALI/PARROT, if you dont use them, you must use a vpn${endColour}"

    echo -e "\n${blueColour}YOUR CURRENT DATA:${endColour}\n"

    echo -n -e "\tIs the script hidding your ip: ${greenColour}$(if [ $stat -eq 1 ]; then echo -e 'Yes'; else echo 'Nou'; fi)${endColour}"
    echo -e "\n\tIP:" $(cat .ip-data | grep "query" | awk 'NF{print $NF}')
    echo -e "\tCITY:" $(cat .ip-data | grep "city" | awk 'NF{print $NF}' | sed 's/,//')
    echo -e "\tCOUNTRY:" $(cat .ip-data | grep 'country"' | awk 'NF{print $NF}' | sed 's/,//')

    rm .ip-data

    echo ""

    echo -n "Do you want continue? y/n: "
    read opt

    if [[ "$opt" == "y" || "$opt" == "Y" ]]; then
        sleep .1
    else
        echo -e "${redColour}\nExiting...${endColour}"

        if [ $stat -eq 1 ]; then
            ps aux | grep "openvpn --config" | grep "root" | awk '{print $2}' | head -n -1 | xargs sudo kill
        fi

        exit 1
    fi

}

function getLink(){

    clear

    echo ""

    echo -n -e "Type the code: ${greenColour}"
    read code

    code=$(echo $code | tr '[:lower:]' '[:upper:]')

    if [ ${#code} != 6 ]; then
        echo -e "\n${redColour}Error code${endColour}\n"
        exit 1
    fi

    curl -A fsociety -s "https://grabify.link/"$code -o .data-response

    if [ $stat -eq 1 ]; then
        ps aux | grep "openvpn --config" | grep "root" | awk '{print $2}' | head -n -1 | xargs sudo kill
    fi

    lines=$(cat .data-response | wc -l)

    if [ $lines -eq 11 ]; then

        link=$(cat .data-response | grep "Redirecting" | head -n 1 | awk 'NF{print $NF}' | sed 's/<\/title>//')

        echo -e "\n${greenColour}READY! The grabify link has been evaded${endColour}\n"

        echo -e "${red}Link: ${purpleColour}$link${endColour}\n"

        rm .data-response

        exit 0
    else

        link=$(cat .data-response | grep  'name="url"' | awk '{print $3}' | cut -d '"' -f 2)


        if [ ${#link} -eq 0 ]; then
            echo -e "\n${redColour}Error, maybe you are using an incompatible vpn/proxy"
            echo -e "\nRead the repository\n${endColour}"
            exit 1
        fi

        echo -e "\n${greenColour}READY! The grabify link has been evaded\n${endColour}"

        echo -e "${redColour}Link: ${purpleColour}$link${endColour}\n"

        rm .data-response

        exit 0

    fi

}

check
getLink
