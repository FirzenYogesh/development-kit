#!/usr/bin/env bash

lowercase() {
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

# check OSTYPE env variable first
# most modern shell should have this variable defined
case $(lowercase "$OSTYPE") in
    linux*) OS="linux" ;;
    darwin*) OS="macos" ;;
    msys*|cygwin*|mingw*) OS="windows" ;;
esac

# if it is not found we try in uname -s
if [ -z "$OS" ]; then
    case $(lowercase "$(uname -s)") in
        linux*) OS="linux" ;;
        darwin*) OS="macos" ;;
        msys*|cygwin*|mingw*) OS="windows" ;;
        *) OS="unknown" ;;
    esac
fi

if [ $OS == "linux" ]; then
    source /etc/os-release
fi

# get the architecture of the OS
OS_ARCHITECTURE=$(uname -m)

echo "OS=$OS; OS_VARIENT=$ID; OS_VERSION=$VERSION_ID; OS_ARCHITECTURE=$OS_ARCHITECTURE"