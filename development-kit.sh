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
    if [[ $tool == "zsh"]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    elif [[ $tool == "nvm"]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"
        nvm install
        npm i -g typescript
    elif [[ $tool == "docker"]]; then
        

    fi
}

if [[ $1 == "install" ]]; then
    if [[ -z "$2" ]]; then
        askWhichTool
    else
        installTool $2
    fi
fi