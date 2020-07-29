#!/usr/bin/env zsh

MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s $1)

if [[ -e $ZSH ]]; then
    source $HOME/.zshrc
fi

if [[ $MODE == "install" ]]; then
    if [[ -e $ZSH ]]; then
        upgrade_oh_my_zsh
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
elif [[ $MODE == "uninstall" ]]; then
    if [[ -e $ZSH ]]; then
        uninstall_oh_my_zsh
    else
        echo "zsh is not installed"
    fi
fi