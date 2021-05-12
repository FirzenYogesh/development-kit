#!/usr/bin/env bash

# Set the mode for this script (install or remove)
MODE="install"

if [[ -z "$1" ]] || [[ $1 == "install" ]] || [[ $1 == "add" ]]; then
    MODE="install"
elif [[ $1 == "uninstall" ]] || [[ $1 == "remove" ]] || [[ $1 == "purge" ]] || [[ $1 == "delete" ]]; then
    MODE="uninstall"
elif [[ $1 == "switch" ]] || [[ $1 == "alter" ]] || [[ $1 == "change" ]]; then
    MODE="switch"
elif [[ $1 == "fix-env" ]]; then
    MODE="fix-env"
else
    echo "Unsupported Operation"
    exit 1
fi

echo $MODE
exit 0
