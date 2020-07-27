#!/usr/bin/env bash

# Set the mode for this script (install or remove)
WORKSPACE="$DEVELOPMENT_KIT_SDK_HOME"
mkdir -p $WORKSPACE

MODE="install"

if [[ -z "$1" ]]; then
    MODE="install"
else
    if [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]]; then
        MODE="uninstall"
    fi
fi

if [[ $MODE == "install "]]; then
    cd $WORKSPACE

    if ! command -v flutter &> /dev/null; then
        sudo apt update
        sudo apt install -y unzip zip curl git xz-utils
        if [[ -e /etc/debian_version ]]; then
            sudo apt install -y libglu1-mesa
        elif [[ -e /etc/fedora-release ]]; then
            sudo dnf -y install mesa-libGLU
        fi
        git clone https://github.com/flutter/flutter.git -b stable --depth 1

        

        echo 'export PATH="$PATH:$DEVELOPMENT_KIT_SDK_HOME/flutter/bin"'
        flutter precache
    else
        flutter upgrade
    fi
    
    flutter doctor
fi