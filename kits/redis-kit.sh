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

REDIS_HOME_PARENT="$DEVELOPMENT_KIT_SDK_HOME/redis"
mkdir -p "$REDIS_HOME_PARENT"

getRedisLink() {
    local version="$1"
    if [[ -z "$version" ]]; then
        version="stable"
    fi
    if [[ "$version" == "latest" ]]; then
        version="stable"
    fi
    echo "https://download.redis.io/releases/redis-$version.tar.gz"
}

if [[ -z "$2" ]]; then
    REDIS_FOLDER="stable"
else
    REDIS_FOLDER="$2"
fi

switchVersion() {
    ln -sfn "$REDIS_HOME_PARENT/$REDIS_FOLDER" "$REDIS_HOME_PARENT/current"
}

setEnv() {
    {
        echo 'export REDIS_HOME="$DEVELOPMENT_KIT_SDK_HOME/redis/current"' 
    } >> "$DEVELOPMENT_KIT_ENV"
    {
        echo 'export PATH="$REDIS_HOME/src:$PATH"'
    } >> "$DEVELOPMENT_KIT_PATHS"
}

cd "$REDIS_HOME_PARENT"

if [[ $MODE == "install" ]]; then
    mkdir -p "$REDIS_FOLDER"
    link="$(getRedisLink "$REDIS_FOLDER")"
    echo "Dowloading Redis from $link"
    file="redis-$REDIS_FOLDER.tar.gz"
    wget -O "$file" "$link"
    tar zxf "$file" -C "$REDIS_FOLDER"
    rm "$file"
    cd "$REDIS_FOLDER"
    make
    switchVersion
    if [[ -z "$REDIS_HOME" ]]; then
        setEnv
    fi
elif [[ $MODE == "uninstall" ]]; then
    rm -rf "$REDIS_FOLDER"
    echo "Please switch the redis version if needed"
elif [[ $MODE == "switch" ]]; then
    switchVersion
elif [[ $MODE == "fix-env" ]]; then
    setEnv
fi
