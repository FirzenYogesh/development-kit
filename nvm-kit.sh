#!/bin/bash

SHELL_DEPENDENCIES="$HOME/.development-tools/.dependencies/shell"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"

echo '# nvm PATH Setup
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> "$SHELL_DEPENDENCIES/paths"

source "$SHELL_DEPENDENCIES/main"

nvm install --lts
nvm install --latest-npm
npm i -g typescript