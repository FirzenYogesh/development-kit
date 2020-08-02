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


WORKSPACE="$DEVELOPMENT_KIT_DB_HOME/redis"
mkdir -p "$WORKSPACE" && cd "$_"

REDIS_CONF="$WORKSPACE/redis.conf"

if [[ -z "$2" ]]; then
    REDIS_VERSION="stable"
else
    REDIS_VERSION="$2"
fi
BASE_URL="http://download.redis.io"
FILE_EXTENSION="tar.gz"

FOLDER_NAME="redis-$REDIS_VERSION"

switchVersion() {
    ln -sfn "$WORKSPACE/$FOLDER_NAME" "$WORKSPACE/current"
}

setEnv() {
    {
        echo 'export REDIS_HOME="$DEVELOPMENT_KIT_DB_HOME/redis/current"' 
    } >> "$DEVELOPMENT_KIT_ENV"
    {
        echo 'export PATH="$REDIS_HOME/bin":"$PATH"'
    } >> "$DEVELOPMENT_KIT_PATHS"
}

if [[ $MODE == "install" ]]; then
    mkdir -p "$FOLDER_NAME"
    FILE="$FOLDER_NAME.$FILE_EXTENSION"
    URL="$BASE_URL/$FILE"
    wget -O "$FILE" "$URL"
    tar zxf "$FILE" -C "$FOLDER_NAME" --strip-components 1

    cd "$FOLDER_NAME"
    make
    make test


    # switchVersion
    # if [[ -z "$REDIS_HOME" ]]; then
    #    setEnv

        # shellcheck disable=SC1090
        # disabling this rule as it is a constant variable
    #    source "$DEVELOPMENT_KIT_MAIN"
    # fi
    # rm "$FILE"
fi
