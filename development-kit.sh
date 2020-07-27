#!/bin/bash

# update the repo
#sudo apt update

# install basic dependencies
#sudo apt install -y unzip zip curl git xz-utils

# tools to install
askWhichTool() {
    echo "What do you want to install?
zsh
nvm
docker
code-server
"

    local tool=""
    read -e -rp "Type ahead with your choice: " tool
    installTool $tool
}

installTool() {
    local tool=$1
    echo "Installing $tool"
    if [[ -e "$tool-kit.sh" ]]; then
        sh -c "$tool-kit.sh"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/FirzenYogesh/development-kit/master/$tool-kit.sh)"
    fi
}

if [[ $1 == "install" ]]; then
    if [[ -z "$2" ]]; then
        askWhichTool
    else
        installTool $2
    fi
fi