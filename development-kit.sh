#!/bin/bash

# update the repo
#sudo apt update

# install basic dependencies
#sudo apt install unzip zip curl git xz-utils

# tools to install
askWhichTool() {
    echo "What do you want to install?
zsh
nvm
docker
code-server
"

    local tool="zsh"
    read -rp "Type ahead with your choice: " -e -i "$tool" tool
}

installTool() {
    local tool=$1
    echo "Installing $tool"
}

if [[ $1 == "install" ]]; then
    if [[ -z "$2" ]]; then
        askWhichTool
    else
        installTool $2
    fi
fi