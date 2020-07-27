#!/usr/bin/env bash

# Set the mode for this script (install or remove)
MODE="install"

if [[ -z "$1" ]]; then
    MODE="install"
else
    if [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]]; then
        MODE="uninstall"
    fi
fi

# Check OS Version

# Debian or Ubuntu
if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    OS=$ID
elif [[ -e /etc/fedora-release ]]; then
    source /etc/os-release
	OS=$ID
elif [[ -e /etc/fedora-release ]]; then
	source /etc/os-release
	OS=$ID
elif [[ -e /etc/centos-release ]]; then
	OS=centos
elif [[ -e /etc/arch-release ]]; then
	OS=arch
    echo "Currently the script does not support Arch Linux"
    exit 1
fi

if [[ $MODE == "install" ]]; then
    if  command -v docker &> /dev/null; then
        echo "Docker is already installed"
        exit 1
    fi
    if [[ $OS == "ubuntu"]]; then
        sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "debian" ]]; then
        sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "fedora" ]]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
    elif [[ $OS == "centos" ]]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
    fi
    sudo docker run hello-world
else
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed"
        exit 1
    fi
    if [[ $OS == "ubuntu"]]; then
        sudo apt-get purge docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "debian"]]; then
        sudo apt-get purge docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "fedora" ]]; then
        sudo dnf remove docker-ce docker-ce-cli containerd.io
    elif [[ $OS == "centos" ]]; then
        sudo yum remove docker-ce docker-ce-cli containerd.io
    fi
    sudo rm -rf /var/lib/docker
fi
