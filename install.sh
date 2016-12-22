#!/bin/bash
dir="$(dirname "$0")"
cd $dir

which docker-machine &>/dev/null

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
    echo $UNDERLINE$GREEN;
    echo -n "Welcome to the Docker-Builder.$NORMAL"
    echo "";
    echo "This script will create a PHP7 Docker VM for your GitHub project."

    # Check docker
    if [ $? -ne 0 ]; then
        echo $ERROR
        echo -n "   ERROR: Please install docker toolbox. https://www.docker.com/products/docker-toolbox $NORMAL"
        exit 1
    fi

    # Check install directory
    if [ "$(ls -A $dir)" ]; then
        echo $WARNING
        echo -n "   WARNING: current directory ($PWD) is not empty!$NORMAL"
        echo ""
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
    echo "";
    echo "Type the name of your GitHub project (in format:  <Namespace>/<Project>), followed by [ENTER]:"
    read -p "> " project
    echo "";
    echo -n "Clone '$project' into the ./sources folder "
    ./progress.sh git clone git@github.com:$project.git ./sources &> /dev/null

    if [[ ! -d "./sources" ]]; then
        echo $ERROR
        echo -n "   ERROR: The $project could not be cloned. $NORMAL"
        exit 1
    else
        echo " Done"
    fi

    # Collect informations
    echo $UNDERLINE$GREEN
    echo "In the following, we need you to give some setup data.$NORMAL"

    read -p "  * VM name (leave blank for default: $VM_NAME)> " input;
    if [[ ! -z "$input" ]]; then
        VM_NAME=$input
    fi

    read -p "  * VM timezone (leave blank for default: $VM_TIMEZONE)> " input;
    if [[ ! -z "$input" ]]; then
        VM_TIMEZONE=$input
    fi

    read -p "  * VM domain name (leave blank for default: $VM_DOMAIN)> " input;
    if [[ ! -z "$input" ]]; then
        VM_DOMAIN=$input
    fi

    read -p "  * VM document root: relative to the ./source folder (leave blank for default: $VM_DOCROOT)> " input;
    if [[ ! -z "$input" ]]; then
        VM_DOCROOT=$input
    fi

    echo $UNDERLINE$GREEN
    echo "Please enter the MySQL credentials for the VM.$NORMAL"

    read -p "  * MySQL user (leave blank for default: $VM_MYSQL_USER)> " input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_USER=$input
    fi

    read -p "  * MySQL password (leave blank for default: $VM_MYSQL_PASSWORD)> " input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_PASSWORD=$input
    fi

    read -p "  * MySQL database (leave blank for default: $VM_MYSQL_DATABASE)> " input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_DATABASE=$input
    fi

    read -p "  * MySQL root password (leave blank for default: $VM_MYSQL_ROOTPASSWORD)> " input;
    if [[ ! -z "$input" ]]; then
        VM_MYSQL_ROOTPASSWORD=$input
    fi

    echo ""
    echo "Data saved, patching Docker resources. "
}
run
