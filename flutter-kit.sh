#!/usr/bin/env bash

mkdir -p $DEVELOPMENT_KIT_SDK_HOME

# Set the mode for this script (install or remove)
MODE="install"

if [[ -z "$1" ]]; then
    MODE="install"
else
    if [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]]; then
        MODE="uninstall"
    fi
fi

if [[ $MODE == "install" ]]; then
    cd $DEVELOPMENT_KIT_SDK_HOME
    if ! command -v flutter &> /dev/null; then
        # Pre-requisite
        if [[ "$OSTYPE" == "linux"* ]]; then
            sudo apt update
            sudo apt install -y unzip zip curl git xz-utils
            if [[ -e /etc/debian_version ]]; then
                sudo apt install -y libglu1-mesa
            elif [[ -e /etc/fedora-release ]]; then
                sudo dnf -y install mesa-libGLU
            fi
        fi

        if [[ "$OSTYPE" == "linux"* ]]; then
            wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.17.5-stable.tar.xz
            tar xvf flutter.tar.xz
            rm flutter.tar.xz
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            git clone https://github.com/flutter/flutter.git -b stable --depth 1
        fi

        if [[ -z "$FLUTTER_HOME" ]]; then
            echo 'export FLUTTER_HOME=$DEVELOPMENT_KIT_SDK_HOME/flutter' >> $DEVELOPMENT_KIT_ENV
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin"' >> $DEVELOPMENT_KIT_PATHS
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin"' >> $DEVELOPMENT_KIT_PATHS
            echo 'export PATH="$PATH:$FLUTTER_HOME/.pub-cache/bin"' >> $DEVELOPMENT_KIT_PATHS
        fi
        source "$DEVELOPMENT_KIT_MAIN"
        flutter precache
    else
        flutter upgrade
    fi
    flutter doctor
else
    if ! command -v flutter &> /dev/null; then
        echo "Flutter is not installed"
    else
        if [[ -d "$DEVELOPMENT_KIT_SDK_HOME/flutter" ]]; then
            rm -rf $DEVELOPMENT_KIT_SDK_HOME/flutter
            echo "Please remove the lines below in $DEVELOPMENT_KIT_PATHS"
            echo 'export PATH="$PATH:$DEVELOPMENT_KIT_SDK_HOME/flutter/bin"'
            echo 'export PATH="$PATH:$DEVELOPMENT_KIT_SDK_HOME/flutter/bin/cache/dart-sdk/bin"'
            echo 'export PATH="$PATH:$DEVELOPMENT_KIT_SDK_HOME/flutter/.pub-cache/bin"'
        else
            TEMP_PATH=$(command -v flutter)
            cd $TEMP_PATH &> /dev/null || cd `dirname $TEMP_PATH`
            cd ..
            CURRENT_FLUTTER_PATH=$(pwd)
            rm -rf $CURRENT_FLUTTER_PATH
            echo "Please remove the PATH related to $CURRENT_FLUTTER_PATH"
        fi
    fi
fi
