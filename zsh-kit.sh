#!/usr/bin/env zsh

# Set the mode for this script (install or remove)
MODE="install"

if [[ -z "$1" ]]; then
    MODE="install"
else
    if [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]]; then
        MODE="uninstall"
    fi
fi

if [[ -e $ZSH ]]; then
    source $HOME/.zshrc
fi

if [[ $MODE == "install" ]]; then
    if [[ -e $ZSH ]]; then
        upgrade_oh_my_zsh
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
else
    if [[ -e $ZSH ]]; then
        uninstall_oh_my_zsh
    else
        echo "zsh is not installed"
    fi
fi