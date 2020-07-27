#!/bin/bash

sh -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"
nvm install --lts
nvm install --latest-npm
npm i -g typescript