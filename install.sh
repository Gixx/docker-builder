#!/bin/bash
dir="$(dirname "$0")"
TERM=xterm
tput init
tput clear
cd $dir

which docker-machine &>/dev/null

SAVE_CURSOR=$(tput sc)
RESTORE_CURSOR=$(tput rc)

BOLD=$(tput bold)
UNDERLINE=$(tput smul)

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput bold;tput setaf 3)
MAGENTA=$(tput bold;tput setaf 5)

ERROR=$(tput bold;tput setb 4)
WARNING=$(tput bold;tput setaf 0;tput setb 6)
NORMAL=$(tput sgr0)

function finish() {
    echo ""
    echo "Finish"
}

function printWarning() {
    col=`expr $(tput cols) - ${#1} - 12`
    echo $WARNING
    echo -n "   WARNING: "
    echo -n $1
    printf "%*s" $col
    echo $NORMAL
}

function printError() {
    col=`expr $(tput cols) - ${#1} - 10`
    echo $ERROR
    echo -n "   ERROR: "
    echo -n $1
    printf "%*s" $col
    echo $NORMAL
}

function printHeadline() {
    echo $UNDERLINE$GREEN;
    echo $1
    echo -n $NORMAL
}

VM_NAME="myproject"
VM_TIMEZONE=$(/bin/ls -l /etc/localtime|/usr/bin/cut -d"/" -f7,8)
VM_DOMAIN="myproject.dev"
VM_DOCROOT="public"

VM_MYSQL_USER="user"
VM_MYSQL_PASSWORD="userpass"
VM_MYSQL_DATABASE=$VM_NAME
VM_MYSQL_ROOTPASSWORD="rootpass"

HOST_IP=$(curl -sL ipecho.net/plain)
HOST_GROUP=$(id -g -n)

trap finish EXIT
shell=$(echo $SHELL | awk -F '/' '{print $NF}')

function run() {
# DEV
cp ./install.sh /tmp/xxx
# DEV END
    echo $GREEN;
    echo "  ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗       ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗"
    echo "  ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗      ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗"
    echo "  ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝█████╗██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝"
    echo "  ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗╚════╝██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗"
    echo "  ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║      ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║"
    echo "  ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝      ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo $NORMAL

    echo "Welcome to the Docker-Builder."
    echo "";
    echo "This script will create a PHP7 Docker VM for your GitHub project."

    # Check docker
    if [ $? -ne 0 ]; then
        printError "Please install docker toolbox. https://www.docker.com/products/docker-toolbox"
        exit 1
    fi

    # Check install directory

    if [ "$(find . ! -name install.sh ! -name .)" ]; then
        printWarning "Current directory ($PWD) is not empty!"

        echo "$BOLD Do you want to delete all files?$NORMAL"
        echo "  * Note: changes cannot be undone!"
        read -p "    [y/n]> " answer;
        [[ $answer = [yY] ]] || return
        rm -rf ./.* ./* &> /dev/null
        echo "  * Files removed"
    else
        echo ""
        echo "$BOLD Do you want to continue?$NORMAL";
        read -p "    [y/n]> " answer;
        [[ $answer = [yY] ]] || return
    fi

    # Clone docker-builder
    if [[ ! -d "./.git" ]]; then
        echo "";
        echo -n "Clone Docker-Builder"
        git clone git@github.com:Gixx/docker-builder.git . &> /dev/null
        # Not to accidentally commit anything back
        # rm -rf ./.git
        echo " ... Done"
# DEV
cp -f /tmp/xxx ./install.sh
# DEV END
        mkdir sources &> /dev/null
    fi

    # Clone user's project
    printHeadline "Type the name of your GitHub project (in format:  <Namespace>/<Project>), followed by [ENTER]:"
    read -p "  > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" project
    echo $NORMAL;
    echo -n "Clone '$project' into the ./sources folder "
    ./progress.sh git clone git@github.com:$project.git ./sources &> /dev/null

    if [[ ! -d "./sources" ]]; then
        printError "The $project could not be cloned!"
        exit 1
    else
        echo " Done"
    fi

    # Collect informations
    printHeadline "In the following, we need you to give some setup data."

    read -p "$NORMAL  * VM name (default: $VM_NAME)                                        > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_NAME=$input
    fi

    read -p "$NORMAL  * VM timezone (default: $VM_TIMEZONE)                                > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_TIMEZONE=$input
    fi

    read -p "$NORMAL  * VM domain name (default: $VM_DOMAIN)                             > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_DOMAIN=$input
    fi

    read -p "$NORMAL  * VM document root: relative to the ./source folder (default: $VM_DOCROOT) > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_DOCROOT=$input
    fi

    printHeadline "Please enter the MySQL credentials for the VM."

    read -p "$NORMAL  * MySQL user (default: $VM_MYSQL_USER)                                          > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_USER=$input
    fi

    read -p "$NORMAL  * MySQL password (default: $VM_MYSQL_PASSWORD)                                  > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_PASSWORD=$input
    fi

    read -p "$NORMAL  * MySQL database (default: $VM_MYSQL_DATABASE)                                 > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_DATABASE=$input
    fi

    read -p "$NORMAL  * MySQL root password (default: $VM_MYSQL_ROOTPASSWORD)                             > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_ROOTPASSWORD=$input
    fi

    echo $NORMAL
    echo "Data saved, patching Docker resources. "
}
run
