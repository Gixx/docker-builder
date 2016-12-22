#!/bin/bash
which docker-machine &>/dev/null

BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput bold;tput setaf 3)
MAGENTA=$(tput bold;tput setaf 5)
ERROR=$(tput bold;tput setb 4)
WARN=$(tput bold;tput setb 6)
NORMAL=$(tput sgr0)

function finish() {
    echo ""
    echo "Finish"
}

trap finish EXIT
shell=$(echo $SHELL | awk -F '/' '{print $NF}')

function cleanup() {
    rm -rf ./sources &> /dev/null
    rm -rf ./.git &> /dev/null
    rm -rf ./.idea &> /dev/null
    rm ./run_with_dots &> /dev/null
    rm README.md &> /dev/null
    rm LICENSE &> /dev/null
    rm docker-compose.yml &> /dev/null
}

function run() {
    cleanup;

    echo $UNDERLINE; echo -n "Welcome to the Docker-Builder.$NORMAL"
    echo "";  echo "This script will create a PHP7 Docker VM for your GitHub project."
    echo "";  read -p "Do you want to continue (y/n)? " -n1 answer; echo; [[ $answer = [yY] ]] || return

    if [ $? -ne 0 ]; then
        echo "Please install docker toolbox. https://www.docker.com/products/docker-toolbox"
        exit 1
    fi

    if [[ ! -d "./.git" ]]; then
        echo ""; echo -n "Clone Docker-Builder "
        # Oh, what a dirty trick!!! >:D
        rm -f ./install.sh &> /dev/null
        git clone git@github.com:Gixx/docker-builder.git . &
        mkdir sources &> /dev/null
    fi

    echo ""; echo "Type the name of your GitHub project (in format:  <Username>/<ProjectName>), followed by [ENTER]:"
    read project
    echo ""; echo -n "Clone '$project' into the ./sources folder "
    ./progress.sh git clone git@github.com:$project.git ./sources &> /dev/null
}
run
