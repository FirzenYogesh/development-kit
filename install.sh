#!/usr/bin/env bash
# shellcheck disable=SC2164

WORKSPACE="$HOME/.development-tools"
mkdir -p "$WORKSPACE"

KIT_PATH="$WORKSPACE/development-kit"

DEPENDENCIES="$WORKSPACE/.dependencies"
mkdir -p "$DEPENDENCIES"

SHELL="$DEPENDENCIES/shell"
mkdir -p "$SHELL"

# Main Shell script resources
MAIN="$SHELL/main"
# PATH variables
SHELL_PATHS="$SHELL/paths"
# ALIASES
ALIASES="$SHELL/aliases"
# env
ENV_PATH="$SHELL/env"

cd "$WORKSPACE"

SHELL_RC="$HOME/.bashrc"
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.profile" ]]; then
    SHELL_RC="$HOME/.profile"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [[ -d "$KIT_PATH" ]]; then
    cd "$KIT_PATH"
    git checkout .
    git checkout main
    git pull
    echo "Please run the following command
source $SHELL_RC"
else
    git clone https://github.com/FirzenYogesh/development-kit.git
    # Setup

    # Main 
    {
        echo "source $ENV_PATH
source $SHELL_PATHS
source $ALIASES"
     } >> "$MAIN"

    # Setup Paths
    {
        # shellcheck disable=SC2016
        echo 'export PATH="$PATH":"$DEVELOPMENT_KIT_HOME"'
        # shellcheck disable=SC2016
        echo 'export PATH="$PATH":"$DEVELOPMENT_KIT_SDK_EXECUTABLES"'
    } >> "$SHELL_PATHS"

    # Setup Aliases
    {
        echo 'alias cl="clear"'
        echo 'alias gs="git status"'
        echo 'alias gd="git diff"'
        echo 'alias gc="git checkout"'
        echo 'alias gpoh="git push origin HEAD"'
    } >> "$ALIASES"

    # Setup env
    {
        echo "export DEVELOPMENT_KIT_HOME=$WORKSPACE
export DEVELOPMENT_KIT_SDK_HOME=$WORKSPACE/sdk
export DEVELOPMENT_KIT_SDK_EXECUTABLES=$WORKSPACE/executables
export DEVELOPMENT_KIT_ALIASES=$ALIASES
export DEVELOPMENT_KIT_ENV=$ENV_PATH
export DEVELOPMENT_KIT_PATHS=$SHELL_PATHS
export DEVELOPMENT_KIT_MAIN=$MAIN"
    } >> "$ENV_PATH"

    # Add to the shell
    echo "# Setup by development-kit
# Check https://github.com/FirzenYogesh/development-kit to know more
source $MAIN
# End of development-kit Setup" >> "$SHELL_RC"
    echo "Please run the following command
source $SHELL_RC"
fi
