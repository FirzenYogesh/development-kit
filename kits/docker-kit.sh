#!/usr/bin/env bash

MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
OS=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os-type.sh" | bash)

if [[ $OS == "arch" ]]; then
    echo "Currently the script does not support Arch Linux"
    exit 1
fi

if [[ $MODE == "install" ]]; then
    if  command -v docker &> /dev/null; then
        echo "Docker is already installed"
        exit 1
    fi
    if [[ $OS == "ubuntu" ]]; then
        sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "debian" ]]; then
        sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "fedora" ]]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
    elif [[ $OS == "centos" ]]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
    fi
    sudo docker run hello-world
elif [[ $MODE == "uninstall" ]]; then
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed"
        exit 1
    fi
    if [[ $OS == "ubuntu" ]]; then
        sudo apt purge -y docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "debian" ]]; then
        sudo apt purge -y docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "fedora" ]]; then
        sudo dnf -y remove docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "centos" ]]; then
        sudo yum remove -y docker-ce docker-ce-cli containerd.io
    fi
    sudo rm -rf /var/lib/docker  
fi
