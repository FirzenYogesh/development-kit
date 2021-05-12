#!/usr/bin/env bash
# run proper init scripts based on execution environment
# DEVLOPMENT_KIT_EXEC_ENV is not set in production to avoid hinderance
KIT=Homebrew
if [[ "$DEVLOPMENT_KIT_EXEC_ENV" == "dev" ]]; then
    MODE=$(./commons/task-mode.sh "$1")
    eval "$(./commons/get-os.sh)"
else
    MODE=$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/task-mode.sh" | bash -s "$1")
    eval "$(curl -o- "https://raw.githubusercontent.com/FirzenYogesh/development-kit/main/commons/get-os.sh" | bash)"
fi

if [[ $OS == "windows" ]]; then
    echo "Unsupported OS"
    exit 1
fi

if [[ $MODE == "install" ]]; then
    if  command -v brew &> /dev/null; then
        echo "Homebrew already exists, updating..."
        brew update
    else
        echo "Homebrew does not exist, installing..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
elif [[ $MODE == "uninstall" ]]; then
    if  command -v brew &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    else
        echo "homebrew is not installed"
    fi
fi

echo "Done $KIT $MODE"
exit 1