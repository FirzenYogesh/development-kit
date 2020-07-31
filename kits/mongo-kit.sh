#!/usr/bin/env bash

MODE=$(./commons/task-mode.sh)
eval $(./commons/get-os.sh)
WORKSPACE="$DEVELOPMENT_KIT_DB_HOME/mongo"
mkdir -p "$WORKSPACE" && cd "$_"

# MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
# eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"

if [[ -z "$2" ]]; then
    MONGO_VERSION="4.4.0"
else
    MONGO_VERSION="$2"
fi
BASE_URL="https://fastdl.mongodb.org"
FILE_EXTENSION="tgz"
FIRST_PATH="$OS"
OS_SPECIFIC=""

if [[ $OS == "linux" ]]; then
    OS_SPECIFIC="$(echo "-$OS_VARIENT${OS_VERSION//'.'/''}")"
elif [[ $OS == "macos" ]]; then
    FIRST_PATH="osx"
elif [[ $OS == "windows" ]]; then
    FILE_EXTENSION="zip"
else
    echo "Unsupported OS"
    exit 1
fi

# URL Should look like this
# https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-4.4.0.tgz
# https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-4.4.0.zip
# https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-4.4.0.tgz

URL="$BASE_URL/$FIRST_PATH/mongodb-$OS-$OS_ARCHITECTURE$OS_SPECIFIC-$MONGO_VERSION.tgz"

echo "Dowloading MongoDB from $URL"

FOLDER_NAME="mongodb-$MONGO_VERSION"

mkdir -p "$FOLDER_NAME"

wget -O "$FOLDER_NAME.$FILE_EXTENSION" "$URL"

tar zxf "$FOLDER_NAME.$FILE_EXTENSION" -C "$FOLDER_NAME"

