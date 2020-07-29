#!/usr/bin/env bash

mkdir -p $DEVELOPMENT_KIT_SDK_HOME

MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s $1)
OS=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)

setEnv() {
    if [[ -z "$FLUTTER_HOME" ]]; then
        echo 'export FLUTTER_HOME=$DEVELOPMENT_KIT_SDK_HOME/flutter' >> $DEVELOPMENT_KIT_ENV
        echo 'export PATH="$FLUTTER_HOME/bin:$PATH"' >> $DEVELOPMENT_KIT_PATHS
        #! To be removed once v1.19 is released in stable
        echo 'export PATH="$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"' >> $DEVELOPMENT_KIT_PATHS
        echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> $DEVELOPMENT_KIT_PATHS
    fi
}

if [[ $MODE == "install" ]]; then
    cd $DEVELOPMENT_KIT_SDK_HOME
    if ! command -v flutter &> /dev/null; then
        # Pre-requisite
        if [[ "$OS" == "linux"* ]]; then
            sudo apt update
            sudo apt install -y unzip zip curl git xz-utils
            if [[ -e /etc/debian_version ]]; then
                sudo apt install -y libglu1-mesa
            elif [[ -e /etc/fedora-release ]]; then
                sudo dnf -y install mesa-libGLU
            fi
        fi

        git clone https://github.com/flutter/flutter.git -b stable

        setEnv

        source "$DEVELOPMENT_KIT_MAIN"
        flutter precache
    else
        flutter upgrade
    fi
    flutter config --no-analytics
    flutter config --enable-web
    flutter config --enable-macos-desktop
    flutter config --enable-linux-desktop
    flutter config --enable-windows-desktop
    flutter config --enable-android-embedding-v2
    flutter doctor
elif [[ $MODE == "switch" ]]; then
    if [[ $2 == "master" ]] || [[ $2 == "dev" ]] || [[ $2 == "beta" ]] || [[ $2 == "stable" ]]; then
        flutter channel $2
        flutter upgrade
    else
        echo "Unsupported operation (should be one of master, dev, beta, stable)"
        exit 1
    fi
elif [[ $MODE == "fix-env" ]]; then
    setEnv
else
    if ! command -v flutter &> /dev/null; then
        echo "Flutter is not installed"
    else
        if [[ -d "$DEVELOPMENT_KIT_SDK_HOME/flutter" ]]; then
            rm -rf $DEVELOPMENT_KIT_SDK_HOME/flutter
            echo "Please remove the lines below in $DEVELOPMENT_KIT_PATHS"
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin"'
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin"'
            echo 'export PATH="$PATH:$FLUTTER_HOME/.pub-cache/bin"'

            echo "Please remove the lines below in $DEVELOPMENT_KIT_ENV"
            echo 'export FLUTTER_HOME=$DEVELOPMENT_KIT_SDK_HOME/flutter'
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
