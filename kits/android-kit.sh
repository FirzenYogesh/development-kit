#!/usr/bin/env bash

WORKSPACE="$DEVELOPMENT_KIT_SDK_HOME/Android"
mkdir -p $WORKSPACE

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
    cd $WORKSPACE
    if [[ "$OSTYPE" == "linux"* ]]; then
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-mac-6609375_latest.zip
    else
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-win-6609375_latest.zip
    fi

    if [[ -d tools ]]; then
        rm -rf tools
    fi
    unzip cmd-tools.zip
    rm cmd-tools.zip

    if [[ -z "$ANDROID_HOME" ]]; then
        # Setting up env
        echo 'export ANDROID_HOME="$DEVELOPMENT_KIT_SDK_HOME/Android"' >> $DEVELOPMENT_KIT_ENV
        echo 'export ANDROID_SDK_ROOT="$DEVELOPMENT_KIT_SDK_HOME/Android"' >> $DEVELOPMENT_KIT_ENV

        # Setup paths
        echo 'export PATH="$ANDROID_HOME/tools:$PATH"' >> $DEVELOPMENT_KIT_PATHS
        echo 'export PATH="$ANDROID_HOME/tools/bin:$PATH"' >> $DEVELOPMENT_KIT_PATHS
        echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> $DEVELOPMENT_KIT_PATHS
        echo 'export PATH="$ANDROID_SDK_ROOT:$PATH"' >> $DEVELOPMENT_KIT_PATHS
    fi

    source "$DEVELOPMENT_KIT_MAIN"

    yes | sdkmanager --sdk_root=${ANDROID_HOME} tools
    yes | sdkmanager "platforms;android-29"
    yes | sdkmanager "platform-tools"
    yes | sdkmanager "patcher;v4"
    yes | sdkmanager "emulator"
    yes | sdkmanager "build-tools;29.0.2"
    yes | sdkmanager --licenses
else
    if [[ -d "$ANDROID_HOME" ]]; then
        rm -rf $ANDROID_HOME
        echo "Please remove the PATH related to $ANDROID_HOME"
    else
        echo "Android SDK is not installed"
    fi
fi