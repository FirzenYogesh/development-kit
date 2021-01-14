#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2164
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

JAVA_HOME_PARENT="$DEVELOPMENT_KIT_SDK_HOME/java"
mkdir -p "$JAVA_HOME_PARENT"

if ! command -v jq &> /dev/null; then
    mkdir -p "$DEVELOPMENT_KIT_EXECUTABLES" && cd "$_"
    if [[ $OS == "linux" ]]; then
        wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    elif [[ $OS == "macos" ]]; then
        wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64
    fi
    chmod +x jq
fi

# get the appropriate jdk link
getJDKLink() {
    local version="$1"
    if [[ -z "$version" ]]; then
        version="jdk8"
    fi
    stripped_version=$(echo "$version" | sed "s/jdk//")
    url=$(echo "https://api.adoptopenjdk.net/v3/assets/latest/$stripped_version/hotspot")
    raw=$(curl "$url")
    for k in $(echo "$raw" | jq '. | keys | .[]'); do
        value=$(echo "$raw" | jq ".[$k]");
        json_os=$(echo "$value" | jq -r '.binary.os')
        image_type=$(echo "$value" | jq -r '.binary.image_type')
        link=$(echo "$value" | jq -r '.binary.package.link')
        # check for OS && check for jdk
        if { [[ "$json_os" == "$OS"* ]] || [[ "$OS" == "$json_os"* ]]; } && [[ $image_type == *jdk* ]] && [[ $link == *x64* ]]; then
            echo "$link"
            break
        fi
    done | column -t -s$'\t'
}

if [[ -z "$2" ]]; then
    JAVA_FOLDER="jdk8"
else
    JAVA_FOLDER="$2"
    if [[ $2 =~ ^[0-9]+ ]]; then
        JAVA_FOLDER="jdk$2"
    fi
fi

switchVersion() {
    ln -sfn "$JAVA_HOME_PARENT/$JAVA_FOLDER" "$JAVA_HOME_PARENT/current"
}

setEnv() {
    {
        echo 'export JAVA_HOME="$DEVELOPMENT_KIT_SDK_HOME/java/current"' 
    } >> "$DEVELOPMENT_KIT_ENV"
    {
        echo 'export PATH="$JAVA_HOME/bin:$PATH"'
    } >> "$DEVELOPMENT_KIT_PATHS"
}

# shellcheck disable=SC2164
# Disabling this rule because we know the directory exists
cd "$JAVA_HOME_PARENT"

if [[ $MODE == "install" ]]; then
    mkdir -p "$JAVA_FOLDER"
    link="$(getJDKLink "$JAVA_FOLDER")"
    wget -O "$JAVA_FOLDER.pack" "$link"
    extension="tar.gz"
    if [[ $OS == "windows" ]]; then
        extension="zip"
    fi
    mv "$JAVA_FOLDER.pack" "$JAVA_FOLDER.$extension"
    tar zxf "$JAVA_FOLDER.$extension" -C "$JAVA_FOLDER" --strip-components 1
    rm "$JAVA_FOLDER.$extension"
    switchVersion
    if [[ -z "$JAVA_HOME" ]]; then
        setEnv
    fi
elif [[ $MODE == "uninstall" ]]; then
    rm -rf "$JAVA_FOLDER"
    echo "Please switch the java version if needed"
elif [[ $MODE == "switch" ]]; then
    switchVersion
elif [[ $MODE == "fix-env" ]]; then
    setEnv
fi
