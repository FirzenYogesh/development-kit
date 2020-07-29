#!/usr/bin/env bash

WORKSPACE="$DEVELOPMENT_KIT_SDK_HOME/Android"
mkdir -p $WORKSPACE

MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s $1)
OS=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)

setEnv() {
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
}

if [[ $MODE == "install" ]]; then
    cd $WORKSPACE
    if [[ "$OS" == "linux"* ]]; then
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
    elif [[ "$OS" == "darwin"* ]]; then
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-mac-6609375_latest.zip
    else
        wget -O cmd-tools.zip https://dl.google.com/android/repository/commandlinetools-win-6609375_latest.zip
    fi

    if [[ -d tools ]]; then
        rm -rf tools
    fi
    unzip cmd-tools.zip
    rm cmd-tools.zip

    setEnv

    source "$DEVELOPMENT_KIT_MAIN"

    mkdir -p ~/.android
    touch ~/.android/repositories.cfg

    yes | sdkmanager --sdk_root=${ANDROID_HOME} tools
    yes | sdkmanager "platforms;android-29" 
    yes | sdkmanager "platforms;android-30"
    yes | sdkmanager "platform-tools"
    yes | sdkmanager "cmdline-tools;latest"
    yes | sdkmanager "patcher;v4"
    yes | sdkmanager "emulator"
    yes | sdkmanager "build-tools;30.0.1"
    yes | sdkmanager "extras;android;m2repository"
    yes | sdkmanager "extras;google;auto"
    yes | sdkmanager "extras;google;google_play_services"
    yes | sdkmanager "extras;google;instantapps"
    yes | sdkmanager "extras;google;market_licensing"
    yes | sdkmanager --licenses
elif [[ $MODE == "fix-env" ]]; then
    setEnv
elif [[ $MODE == "uninstall" ]]; then
    if [[ -d "$ANDROID_HOME" ]]; then
        rm -rf $ANDROID_HOME
        echo "Please remove the following lines in $DEVELOPMENT_KIT_ENV"
        echo 'export ANDROID_HOME="$DEVELOPMENT_KIT_SDK_HOME/Android"'
        echo 'export ANDROID_SDK_ROOT="$DEVELOPMENT_KIT_SDK_HOME/Android"'

        echo "Please remove the following lines in $DEVELOPMENT_KIT_PATHS"
        echo 'export PATH="$ANDROID_HOME/tools:$PATH"'
        echo 'export PATH="$ANDROID_HOME/tools/bin:$PATH"'
        echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"'
        echo 'export PATH="$ANDROID_SDK_ROOT:$PATH"'
    else
        echo "Android SDK is not installed"
    fi
else
    echo "Unsupported Operation"
    exit 1
fi
