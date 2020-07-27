#!/usr/bin/env bash

WORKSPACE="$HOME/.development-tools"
mkdir -p $WORKSPACE

KIT_PATH="$WORKSPACE/development-kit"

DEPENDENCIES="$WORKSPACE/.dependencies"
mkdir -p $DEPENDENCIES

SHELL="$DEPENDENCIES/shell"
mkdir -p $SHELL

# Main Shell script resources
MAIN="$SHELL/main"
# PATH variables
SHELL_PATHS="$SHELL/paths"
# ALIASES
ALIASES="$SHELL/aliases"

cd $WORKSPACE

SHELL_RC="$HOME/.bashrc"
if [[ -e "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -e "$HOME/.profile" ]]; then
    SHELL_RC="$HOME/.profile"
elif [[ -e "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [[ -e "$KIT_PATH" ]]; then
    cd $KIT_PATH
    git checkout .
    git checkout main
    git pull
    source $SHELL_RC
else
    git clone https://github.com/FirzenYogesh/development-kit.git
    # Setup

    # Main 
    echo "source $SHELL_PATHS
source $ALIASES" >> $MAIN

    # Setup Paths
    echo "export PATH=\"\$PATH:$KIT_PATH\"" >> $SHELL_PATHS

    # Setup Aliases
    echo "cl=clear" >> $ALIASES

    # Add to the shell
    echo "# Setup by development-kit
# Check https://github.com/FirzenYogesh/development-kit to know more
source $MAIN
# End of development-kit Setup" >> "$SHELL_RC"

    #source $SHELL_RC
fi
