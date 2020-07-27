#!/bin/bash

MODE="install"

if [[ -z "$1" ]]; then
    if [ $1 == "uninstall" || $1 == "remove" || $1 == "purge" ]; then
        MODE="uninstall";
    fi
fi

if [[$MODE == "install"]]; then
    if [[ -e "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        upgrade_oh_my_zsh
    fi
else
    uninstall_oh_my_zsh
fi