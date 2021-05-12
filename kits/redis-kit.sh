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
REDIS_DATA="$WORKSPACE/data"
REDIS_LOG="$WORKSPACE/log"

mkdir -p "$REDIS_DATA"
mkdir -p "$REDIS_LOG"

if [[ $OS == "linux" ]]; then
    SERVICE_FILE="/usr/lib/systemd/user/redis-server.service"
elif [[ $OS == "macos" ]]; then
    SERVICE_FILE="$HOME/Library/LaunchAgents/development-kit.redis-server.plist"
fi

macosDaemonFile() {
echo "
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
    <dict>
        <key>Label</key>
        <string>development-kit.redis-server</string>
        <key>ProgramArguments</key>
        <array>
            <string>$REDIS_HOME/src/redis-server</string>
            <string>--config</string>
            <string>$REDIS_HOME</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>WorkingDirectory</key>
        <string>/usr/local</string>
        <key>StandardErrorPath</key>
        <string>$REDIS_HOME/redis-server.log</string>
        <key>StandardOutPath</key>
        <string>$REDIS_HOME/redis-server.log</string>
        <key>HardResourceLimits</key>
        <dict>
            <key>NumberOfFiles</key>
            <integer>4096</integer>
        </dict>
        <key>SoftResourceLimits</key>
        <dict>
            <key>NumberOfFiles</key>
            <integer>4096</integer>
        </dict>
    </dict>
</plist>
" | sudo tee -a "$SERVICE_FILE" >/dev/null
}

linuxDaemonFile() {
echo "
# generated by development-kit

[Unit]
Description=Redis Server
After=network.target
Documentation=https://redis.io/documentation

[Service]

Restart=on-failure
RestartSec=5s

Type=exec
EnvironmentFile=-$WORKSPACE/redis-server.env
ExecStart=$REDIS_HOME/src/redis-server $REDIS_CONF
PIDFile=$WORKSPACE/redis-server.pid

# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false

[Install]
WantedBy=default.target
" | sudo tee -a "$SERVICE_FILE" >/dev/null
}

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
    ln -sfn "$WORKSPACE/$REDIS_FOLDER" "$WORKSPACE/current"
}

setEnv() {
    {
        echo 'export REDIS_HOME="$DEVELOPMENT_KIT_DB_HOME/redis/current"' 
    } >> "$DEVELOPMENT_KIT_ENV"
    {
        echo 'export PATH="$REDIS_HOME/src:$PATH"'
    } >> "$DEVELOPMENT_KIT_PATHS"
}

if [[ $MODE == "install" ]]; then
    mkdir -p "$REDIS_FOLDER"
    link="$(getRedisLink "$REDIS_FOLDER")"
    echo "Dowloading Redis from $link"
    file="redis-$REDIS_FOLDER.tar.gz"
    wget -O "$file" "$link"
    tar zxf "$file" -C "$REDIS_FOLDER" --strip-components 1
    rm "$file"
    cd "$REDIS_FOLDER"
    make
    make test

    # generate a redis configuration file
    # skip if the config file exists
    if  [[ -f "$REDIS_CONF" ]]; then
        echo "A redis configuration already exists. Skipping the auto generation of config file"
    else
        wget -O "$REDIS_CONF" "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/config/redis.conf"
    fi

    if  [[ -f "$SERVICE_FILE" ]]; then
        echo "A redis configuration already exists. Skipping the auto generation of config file"
    else
        if [[ $OS == "linux" ]]; then
            # file to be linked
            LOCAL_USER_SERVICE_FILE="$HOME/.config/systemd/user/default.target.wants/redis-server.service"
            mkdir -p "$(dirname "$LOCAL_USER_SERVICE_FILE")"
            linuxDaemonFile
            # link the service file
            ln -sfn "$SERVICE_FILE" "$LOCAL_USER_SERVICE_FILE"
            systemctl --user start redis-server.service
            systemctl --user enable redis-server.service
        elif [[ $OS == "macos" ]]; then
            macosDaemonFile

            launchctl start development-kit.redis-server
            launchctl enable development-kit.redis-server
        fi
    fi

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
exit 0
