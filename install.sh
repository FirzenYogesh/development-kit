WORKSPACE="$HOME/.tools"
mkdir -p $WORKSPACE

cd $WORKSPACE

if [[ -e "$WORKSPACE/development-kit" ]]; then
    git pull orign main
else
    git clone https://github.com/FirzenYogesh/development-kit.git