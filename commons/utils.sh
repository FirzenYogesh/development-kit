#!/usr/bin/env bash

checkIfFileExists() {
    [[ -e "$1" ]] 2>&1
}

checkIfFolderExists() {
    [[ -d "$1" ]] 2>&1
}

commandExists() {
    command -v "$1" >/dev/null 2>&1
}

softLink() {
    echo "Creating a soft link $1 -> $2"
    ln -sfn "$1" "$2"
}

writeToFile() {
    local content=$1
    local file=$2
    local sudo=$3
    if sudo; then
        echo "$1" | sudo tee -a "$file" >/dev/null
    else
        echo "$1" | tee -a "$file" >/dev/null
    fi
}

downloadFile() {
    local file="$1"
    local link="$2"
    if [[ -z "$file" ]]; then
        wget "$link"
    else
        wget -O "$file" "$link"
    fi
}
