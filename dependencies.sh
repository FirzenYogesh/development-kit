#!/usr/bin/env bash

# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    eval "$(./commons/get-os.sh)"
else
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi

if [[ $OS == "linux" ]]; then
    if [[ $OS_VARIENT == "ubuntu" ]] || [[ $OS_VARIENT == "debian" ]] ; then
        sudo apt update

        # docker dependencies
        sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

        # flutter dependencies
        sudo apt install -y unzip zip curl git xz-utils libglu1-mesa
        
        # redis dependencies
        sudo apt install -y make build-essential tcl
    elif [[ $OS_VARIENT == "fedora" ]]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf -y install mesa-libGLU
    elif [[ $OS_VARIENT == "centos" ]]; then
        sudo yum install -y yum-utils
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y tcl
    fi
elif [[ $OS == "macos" ]]; then
    xcode-select --install
fi