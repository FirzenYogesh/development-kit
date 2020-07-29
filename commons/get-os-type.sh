#!/usr/bin/env bash

if [[ $OSTYPE == "linux"* ]]; then
    if [[ -e /etc/debian_version ]]; then
        source /etc/os-release
        OS=$ID
    elif [[ -e /etc/fedora-release ]]; then
        source /etc/os-release
        OS=$ID
    elif [[ -e /etc/fedora-release ]]; then
        source /etc/os-release
        OS=$ID
    elif [[ -e /etc/centos-release ]]; then
        OS=centos
    elif [[ -e /etc/arch-release ]]; then
        OS=arch
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo $OS
