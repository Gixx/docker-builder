#!/bin/bash
which docker-machine &>/dev/null

function finish() {
    echo "finish"
}

trap finish EXIT
shell=$(echo $SHELL | awk -F '/' '{print $NF}')

function run() {
    if [ $? -ne 0 ]; then
        echo "Please install docker toolbox. https://www.docker.com/products/docker-toolbox"
        exit 1
    fi
    if [[ ! -d "./.git" ]]; then
        echo "Clone GPS-Tool Docker"
        # Oh, what a dirty trick!!! >:D
        rm -f ./install.sh
        git clone git@git.westwing.eu:docker/gps-tool.git .
        echo "Clone GPS-Tool sources"
        mkdir sources
        git clone git@git.westwing.eu:devops/gps-tool.git ./sources
    fi
}
run 
