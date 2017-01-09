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
    echo ""
    echo $UNDERLINE$GREEN;
    echo $1
    echo -n $NORMAL
}

VM_NAME="myproject"
VM_TIMEZONE=$(/bin/ls -l /etc/localtime|/usr/bin/cut -d"/" -f7,8)
VM_DOMAIN="myproject.dev"
VM_DOCROOT=""

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
    #cp ./install.sh /tmp/xxx
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

    printHeadline "Clone Docker-Builder."

    # Check install directory
    if [ "$(find . ! -name install.sh ! -name .)" ]; then
        printWarning "Current directory ($PWD) is not empty!"

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

    echo "  * Clone repository"
    git clone git@github.com:Gixx/docker-builder.git . &> /dev/null
    # Not to accidentally commit anything back
    rm -rf ./.git
    echo "    ... Done"

    # DEV
    #cp -f /tmp/xxx ./install.sh
    # DEV END
    mkdir sources &> /dev/null

    # Clone user's project
    printHeadline "Clone GitHub project..."
    echo  "$BOLD Type the name of your GitHub project (in format:  <Namespace>/<Project>), followed by [ENTER]:$NORMAL"
    read -p "  * > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" project
    echo "$NORMAL  * Clone '$project' into the ./sources folder"
    ./progress.sh git clone git@github.com:$project.git ./sources &> /dev/null

    if [[ ! -d "./sources" ]]; then
        printError "The $project could not be cloned!"
        exit 1
    else
        echo "... Done"
    fi

    # Collect informations
    printHeadline "In the following, we need you to give some setup data..."

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

    read -p "$NORMAL  * VM document root: relative to the ./source folder (default is '.')  > $UNDERLINE$SAVE_CURSOR                         $RESTORE_CURSOR" input;
    if [[ ! -z "$input" ]]; then
        VM_DOCROOT=$input
    fi

    printHeadline "Please enter the MySQL credentials for the VM..."

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

    printHeadline "Data saved, patching Docker resources..."
    grep -lR "%host.ip%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%host.ip%/$HOST_IP/g\" @"
    grep -lR "%host.group%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%host.group%/$HOST_GROUP/g\" @"
    grep -lR "%vm.name%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.name%/$VM_NAME/g\" @"
    grep -lR "%vm.timezone%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s#%vm.timezone%#$VM_TIMEZONE#g\" @"
    grep -lR "%vm.domain%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.domain%/$VM_DOMAIN/g\" @"
    grep -lR "%vm.docroot%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.docroot%/$VM_DOCROOT/g\" @"
    grep -lR "%vm.mysql.user%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.mysql.user%/$VM_MYSQL_USER/g\" @"
    grep -lR "%vm.mysql.password%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.mysql.password%/$VM_MYSQL_PASSWORD/g\" @"
    grep -lR "%vm.mysql.database%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.mysql.database%/$VM_MYSQL_DATABASE/g\" @"
    grep -lR "%vm.mysql.rootpassword%" * | grep -v install.sh | xargs -I@ sh -c "echo \"  * @\"; sed -i '' \"s/%vm.mysql.rootpassword%/$VM_MYSQL_ROOTPASSWORD/g\" @"
    echo -n "    ... Done"

    # Time to DOCK'ER! ;)
    printHeadline "Create Docker VM for $project..."

    rm -f /tmp/docker-create.log &> /dev/null
    rm -f /tmp/docker-compose.log &> /dev/null

    status=$(docker-machine status $VM_NAME 2>&1)
    if [[ "$?" != "1" ]]; then
        echo "  * Delete existing VirtualBox image"
        if [[ "$status" == "Running" ]]; then
            docker-machine stop $VM_NAME &> /tmp/docker-create.log
        fi
        docker-machine rm -f $VM_NAME &> /tmp/docker-create.log
        echo "    ... Done"
    fi

    echo "  * Create VirtualBox image ( tail -f /tmp/docker-create.log )"
    ./progress.sh docker-machine create -d virtualbox --virtualbox-host-dns-resolver --virtualbox-cpu-count=2 --virtualbox-memory=2048 --virtualbox-hostonly-cidr="172.17.0.1/16" $VM_NAME &> /tmp/docker-create.log
    echo "... Done"
    eval $(docker-machine env $VM_NAME)

    OS=$(uname)
    if [[ "$OS" == "Darwin" ]]; then
        echo "  * Installing NFS utils"
        ./progress.sh docker-machine ssh $VM_NAME tce-load -wi nfs-utils &> /dev/null
        echo "... Done"

        rcode=$(cat /etc/exports | grep "172\.17\.0\.0")
        if [[ $rcode != 0 ]]; then
            echo "  * Update NFS config and restart service"
            echo | sudo tee -a /etc/exports &> /dev/null
            echo "$(pwd) -network 172.17.0.0 -mask 255.255.255.0 -alldirs -maproot=$USER" | sudo tee -a /etc/exports &> /dev/null
            echo | sudo tee -a /etc/exports &> /dev/null
            awk '!a[$0]++' /etc/exports | sudo tee /etc/exports &> /dev/null
            sudo nfsd restart &> /dev/null
            echo "    ... Done"
            sleep 2
        fi
        sudo nfsd checkexports &> /dev/null
        echo "  * Mount folders"
        docker-machine ssh $VM_NAME 'echo "sudo umount $(pwd) || true" | sudo tee /var/lib/boot2docker/bootlocal.sh' &> /dev/null
        docker-machine ssh $VM_NAME 'echo "sudo /usr/local/etc/init.d/nfs-client start" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null
        docker-machine ssh $VM_NAME 'echo "sudo mount -t nfs -o noacl,async 172.17.0.1:/Users $(pwd)" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null
        echo "    ... Done"

        echo "  * Restart VM"
        ./progress.sh docker-machine restart $VM_NAME &> /dev/null
        echo "... Done"
    fi

    echo "  * Compose containers ( tail -f /tmp/docker-compose.log )"
    ./progress.sh docker-compose up -d --force-recreate &>  /tmp/docker-compose.log
    if [ $? -ne 0 ]; then
        printError "Couldn't start containers!"
        exit 1
    fi
    echo "... Done"

    VM_IP=$(docker-machine ip $VM_NAME)

    printHeadline "Finished!"

    echo 'Put into /etc/hosts:'
    echo ''
    echo "    $VM_IP $VM_DOMAIN"
    echo ''
    echo 'In new terminal before start use always:'
    echo ''
    echo "    eval \$(docker-machine env $VM_NAME)"
}
run
