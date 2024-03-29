#!/usr/bin/env bash
# shellcheck disable=SC2016
# disabling this entirely in the current file 
# because we need to maintain the string
# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    MODE=$(./commons/task-mode.sh "$1")
    eval "$(./commons/get-os.sh)"
else
    MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi

sudoCommand=""

if [[ "$EUID" -ne 0 ]]; then
    sudoCommand="sudo "
fi

mkdir -p "$DEVELOPMENT_KIT_SDK_HOME"

setEnv() {
    if [[ -z "$FLUTTER_HOME" ]]; then
        {
            echo 'export FLUTTER_HOME=$DEVELOPMENT_KIT_SDK_HOME/flutter'
        } >> "$DEVELOPMENT_KIT_ENV"
        
        {
            echo 'export PATH="$FLUTTER_HOME/bin:$PATH"'
            #! To be removed once v1.19 is released in stable
            echo 'export PATH="$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"'
            echo 'export PATH="$HOME/.pub-cache/bin:$PATH"'
        } >> "$DEVELOPMENT_KIT_PATHS"
    fi
}

if [[ -z "$2" ]]; then
    CHANNEL="stable"
elif [[ $2 == "master" ]] || [[ $2 == "dev" ]] || [[ $2 == "beta" ]] || [[ $2 == "stable" ]]; then
    CHANNEL="$2"
else
    echo "Unsupported operation (should be one of master, dev, beta, stable)"
    exit 1
fi

if [[ $MODE == "install" ]]; then
    # shellcheck disable=SC2164
    # Disabling this rule because we know the directory exists
    cd "$DEVELOPMENT_KIT_SDK_HOME"
    if ! command -v flutter &> /dev/null; then
        # Pre-requisite
        if [[ "$OS" == "linux"* ]]; then
            eval "${sudoCommand}apt update"
            eval "${sudoCommand}apt install -y unzip zip curl git xz-utils clang cmake ninja-build pkg-config"
            if [[ $OS_VARIENT == "ubuntu" ]] || [[ $OS_VARIENT == "debian" ]]; then
                eval "${sudoCommand}apt install -y libglu1-mesa"
            elif [[ $OS_VARIENT == "fedora" ]]; then
                eval "${sudoCommand}dnf -y install mesa-libGLU"
            fi
        fi

        git clone https://github.com/flutter/flutter.git -b "$CHANNEL"

        setEnv

        # shellcheck disable=SC1090
        # disabling this rule as it is a constant variable
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
    flutter packages pub global activate devtools
    flutter packages pub global activate webdev
elif [[ $MODE == "switch" ]]; then
    flutter channel "$CHANNEL"
    flutter upgrade
elif [[ $MODE == "fix-env" ]]; then
    setEnv
elif [[ $MODE == "uninstall" ]]; then
    if ! command -v flutter &> /dev/null; then
        echo "Flutter is not installed"
    else
        if [[ -d "$DEVELOPMENT_KIT_SDK_HOME/flutter" ]]; then
            rm -rf "$DEVELOPMENT_KIT_SDK_HOME/flutter"
            echo "Please remove the lines below in $DEVELOPMENT_KIT_PATHS"
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin"'
            echo 'export PATH="$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin"'
            echo 'export PATH="$PATH:$FLUTTER_HOME/.pub-cache/bin"'

            echo "Please remove the lines below in $DEVELOPMENT_KIT_ENV"
            echo 'export FLUTTER_HOME=$DEVELOPMENT_KIT_SDK_HOME/flutter'
        else
            TEMP_PATH=$(command -v flutter)
            cd "$TEMP_PATH" &> /dev/null || cd "$(dirname "$TEMP_PATH")" || exit 1
            cd ..
            CURRENT_FLUTTER_PATH=$(pwd)
            rm -rf "$CURRENT_FLUTTER_PATH"
            echo "Please remove the PATH related to $CURRENT_FLUTTER_PATH"
        fi
    fi
fi
exit 0
