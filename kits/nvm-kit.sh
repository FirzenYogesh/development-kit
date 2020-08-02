#!/usr/bin/env bash

# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    MODE=$(./commons/task-mode.sh "$1")
    eval "$(./commons/get-os.sh)"
else
    MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi

SHELL_DEPENDENCIES="$HOME/.development-tools/.dependencies/shell"

# shellcheck disable=SC2016
# disabling this because this is the exact string we need in the paths file
NVM_PATH='# nvm PATH Setup\nexport NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm\n[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n'

setEnv() {
    if [[ ! -e $NVM_DIR ]]; then
        {
            echo -e "$NVM_PATH"
        } >> "$SHELL_DEPENDENCIES/paths"
    fi
}

if [[ $MODE == "install" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"

    setEnv

    # shellcheck disable=SC1090
    # disabling this rule as it is a constant variable
    source "$SHELL_DEPENDENCIES/main"

    nvm install node
    nvm install --lts
    nvm install --latest-npm
    npm i -g typescript
elif [[ $MODE == "fix-env" ]]; then
    setEnv
elif [[ $MODE == "switch" ]]; then
    nvm use "$2"
elif [[ $MODE == "uninstall" ]]; then
    if [[ -e $NVM_DIR ]]; then
        rm -rf "$NVM_DIR"
        echo "Please remove the lines below in $SHELL_DEPENDENCIES/paths"
        echo "$NVM_PATH"
    else
        echo "nvm is not installed"
    fi
fi