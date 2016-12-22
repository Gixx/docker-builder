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
        echo "Clone Docker-Builder"
        # Oh, what a dirty trick!!! >:D
        rm -f ./install.sh
        git clone git@github.com:Gixx/docker-builder.git .
        mkdir sources
    fi
}
run 
