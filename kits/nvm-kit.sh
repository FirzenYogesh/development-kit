#!/usr/bin/env bash

# Set the mode for this script (install or remove)
MODE="install"

if [[ -z "$1" ]]; then
    MODE="install"
else
    if [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]]; then
        MODE="uninstall"
    fi
fi

SHELL_DEPENDENCIES="$HOME/.development-tools/.dependencies/shell"

NVM_PATH='# nvm PATH Setup\nexport NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm\n[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n'

if [[ $MODE == "install" ]]; then
    if [[ ! -e $NVM_DIR ]]; then
        echo -e $NVM_PATH >> "$SHELL_DEPENDENCIES/paths"
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"

    source "$SHELL_DEPENDENCIES/main"

    nvm install node
    nvm install --lts
    nvm install --latest-npm
    npm i -g typescript
else
    if [[ -e $NVM_DIR ]]; then
        rm -rf "$NVM_DIR"
        echo "Please remove the lines below in $SHELL_DEPENDENCIES/paths"
        echo $NVM_PATH
    else
        echo "nvm is not installed"
    fi
fi