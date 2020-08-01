#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2164
# disabling this entirely in the current file 
# because we need to maintain the string

# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    MODE=$(./commons/task-mode.sh "$1")
    eval "$(./commons/get-os.sh)"
else
    MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi


WORKSPACE="$DEVELOPMENT_KIT_DB_HOME/mongo"
mkdir -p "$WORKSPACE" && cd "$_"

MONGO_CONF="$WORKSPACE/mongod.conf"
MONGO_DATA="$WORKSPACE/data"
MONGO_LOG="$WORKSPACE/log"

mkdir -p "$MONGO_DATA"
mkdir -p "$MONGO_LOG"

if [[ -z "$2" ]]; then
    MONGO_VERSION="4.4.0"
else
    MONGO_VERSION="$2"
fi
BASE_URL="https://fastdl.mongodb.org"
FILE_EXTENSION="tgz"
FIRST_PATH="$OS"
OS_SPECIFIC=""

if [[ $OS == "linux" ]]; then
    OS_SPECIFIC="$(echo "-$OS_VARIENT${OS_VERSION//'.'/''}")"
elif [[ $OS == "macos" ]]; then
    FIRST_PATH="osx"
elif [[ $OS == "windows" ]]; then
    FILE_EXTENSION="zip"
else
    echo "Unsupported OS"
    exit 1
fi

FOLDER_NAME="mongodb-$MONGO_VERSION"

switchVersion() {
    ln -sfn "$WORKSPACE/$FOLDER_NAME" "$WORKSPACE/current"
}

setEnv() {
    {
        echo 'export MONGO_HOME="$DEVELOPMENT_KIT_DB_HOME/mongo/current"' 
    } >> "$DEVELOPMENT_KIT_ENV"
    {
        echo 'export PATH="$PATH":"$MONGO_HOME/bin"'
    } >> "$DEVELOPMENT_KIT_PATHS"
}

mongoConfigFile() {
echo "
# generated by development-kit

# Where and how to store data.
storage:
    dbPath: $MONGO_DATA
    journal:
        enabled: true

# where to write logging data.
systemLog:
    destination: file
    logAppend: true
    path: $MONGO_LOG/mongod.log

# network interfaces
net:
    port: 27017
    bindIp: 127.0.0.1

# how the process runs
processManagement:
    timeZoneInfo: /usr/share/zoneinfo
" | tee -a "$MONGO_CONF" >/dev/null
}

macosDaemonFile() {
echo "
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
    <dict>
        <key>Label</key>
        <string>development-kit.mongodb</string>
        <key>ProgramArguments</key>
        <array>
            <string>$MONGO_HOME/bin/mongod</string>
            <string>--config</string>
            <string>$MONGO_CONF</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>WorkingDirectory</key>
        <string>/usr/local</string>
        <key>StandardErrorPath</key>
        <string>$MONGO_LOG/mongod.log</string>
        <key>StandardOutPath</key>
        <string>$MONGO_LOG/mongod.log</string>
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
Description=MongoDB Database Server
After=network.target
Documentation=https://docs.mongodb.org/manual

[Service]

Restart=on-failure
RestartSec=5s

Type=exec
EnvironmentFile=-$WORKSPACE/mongod.env
ExecStart=$MONGO_HOME/bin/mongod --config $MONGO_CONF
PIDFile=$WORKSPACE/mongod.pid

[Install]
WantedBy=default.target
" | sudo tee -a "$SERVICE_FILE" >/dev/null
}

if [[ $OS == "linux" ]]; then
    SERVICE_FILE="/usr/lib/systemd/user/mongod.service"
elif [[ $OS == "macos" ]]; then
    SERVICE_FILE="$HOME/Library/LaunchAgents/development-kit.mongodb.plist"
fi

if [[ $MODE == "install" ]]; then
    # URL Should look like this
    # https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-4.4.0.tgz
    # https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-4.4.0.zip
    # https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-4.4.0.tgz

    URL="$BASE_URL/$FIRST_PATH/mongodb-$OS-$OS_ARCHITECTURE$OS_SPECIFIC-$MONGO_VERSION.tgz"

    echo "Dowloading MongoDB from $URL"

    mkdir -p "$FOLDER_NAME"

    wget -O "$FOLDER_NAME.$FILE_EXTENSION" "$URL"
    
    tar zxf "$FOLDER_NAME.$FILE_EXTENSION" -C "$FOLDER_NAME" --strip-components 1

    switchVersion
    if [[ -z "$MONGO_HOME" ]]; then
        setEnv

        # shellcheck disable=SC1090
        # disabling this rule as it is a constant variable
        source "$DEVELOPMENT_KIT_MAIN"
    fi
    rm "$FOLDER_NAME.$FILE_EXTENSION"


    # generate a mongo configuration file
    # skip if the config file exists
    if  [[ -f "$MONGO_CONF" ]]; then
        echo "A mongo configuration already exists. Skipping the auto generation of config file"
    else
        mongoConfigFile
    fi


    # generate the service configuration file
    # skip if it exists
    if  [[ -f "$SERVICE_FILE" ]]; then
        echo "A mongo configuration already exists. Skipping the auto generation of config file"
    else
        if [[ $OS == "linux" ]]; then
            # file to be linked
            LOCAL_USER_SERVICE_FILE="$HOME/.config/systemd/user/default.target.wants/mongod.service"
            mkdir -p "$(dirname "$LOCAL_USER_SERVICE_FILE")"
            linuxDaemonFile
            # link the service file
            ln -sfn "$SERVICE_FILE" "$LOCAL_USER_SERVICE_FILE"
            systemctl --user start mongod.service
            systemctl --user enable mongod.service
        elif [[ $OS == "macos" ]]; then
            macosDaemonFile

            launchctl start development-kit.mongodb
            launchctl enable development-kit.mongodb
        fi
    fi
elif [[ $MODE == "switch" ]]; then
    systemctl --user stop mongod.service
    switchVersion
    systemctl --user start mongod.service
elif [[ $MODE == "uninstall" ]]; then
    systemctl --user stop mongod.service
    rm -rf "$FOLDER_NAME"
    echo "Please switch the mongo version if needed"
elif [[ $MODE == "fix-env" ]]; then
    setEnv
fi