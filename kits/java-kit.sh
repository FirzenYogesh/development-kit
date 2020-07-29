#!/usr/bin/env bash

JAVA_HOME_PARENT="$DEVELOPMENT_KIT_SDK_HOME/java"
mkdir -p $JAVA_HOME_PARENT

MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s $1)
OS=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)

# get the appropriate jdk link
getJDKLink() {
    local version=$1
    if [[ -z "$version" ]]; then
        version="jdk8"
    fi
    if [[ $OS == "linux" ]]; then
        if [[ $version == "jdk14" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk14-binaries/releases/download/jdk-14.0.2%2B12/OpenJDK14U-jdk_x64_linux_hotspot_14.0.2_12.tar.gz
        elif [[ $version == "jdk11" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz
        elif [[ $version == "jdk8" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u262-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u262b10.tar.gz
        fi
    elif [[ $OS == "macos" ]]; then
        if [[ $version == "jdk14" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk14-binaries/releases/download/jdk-14.0.2%2B12/OpenJDK14U-jdk_x64_mac_hotspot_14.0.2_12.tar.gz
        elif [[ $version == "jdk11" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_mac_hotspot_11.0.8_10.tar.gz
        elif [[ $version == "jdk8" ]]; then
            link=https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u262-b10/OpenJDK8U-jdk_x64_mac_hotspot_8u262b10.tar.gz
        fi
    fi
    echo $link
}

if [[ -z "$2" ]]; then
    JAVA_FOLDER="jdk8"
else
    JAVA_FOLDER=$2
    if [[ $2 =~ ^[0-9]+ ]]; then
        JAVA_FOLDER="jdk$2"
    fi
fi

switchVersion() {
    ln -sfn "$JAVA_HOME_PARENT/$JAVA_FOLDER" "$JAVA_HOME_PARENT/current"
}

setEnv() {
    echo 'export JAVA_HOME="$DEVELOPMENT_KIT_SDK_HOME/java/current"' >> $DEVELOPMENT_KIT_ENV
    echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> $DEVELOPMENT_KIT_PATHS
}

cd "$JAVA_HOME_PARENT"

if [[ $MODE == "install" ]]; then
    mkdir -p "$JAVA_FOLDER"
    link=$(getJDKLink $JAVA_FOLDER)
    wget -O "$JAVA_FOLDER.tar.gz" "$link"
    tar zxf "$JAVA_FOLDER.tar.gz" -C "$JAVA_FOLDER" --strip-components 1
    rm "$JAVA_FOLDER.tar.gz"
    switchVersion
    if [[ -z "$JAVA_HOME" ]]; then
        setEnv
    fi
elif [[ $MODE == "uninstall" ]]; then
    rm -rf $JAVA_FOLDER
    echo "Please switch the java version if needed"
elif [[ $MODE == "switch" ]]; then
    switchVersion
elif [[ $MODE == "fix-env" ]]; then
    setEnv
fi
