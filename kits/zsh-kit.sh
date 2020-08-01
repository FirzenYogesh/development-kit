#!/usr/bin/env zsh

# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    MODE=$(./commons/task-mode.sh "$1")
    eval "$(./commons/get-os.sh)"
else
    MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi

if [[ -e $ZSH ]]; then
    source "$HOME/.zshrc"
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