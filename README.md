# development-kit

Set of scripts to setup a new development environment

## Why?

Ever felt the frustration of installing and setting up a server or your workstation?

Well that's why!

This repo is aims to be a one stop for all your major development tools/dependencies!

PS: All the script here assumes you want a stable build of the tools available.

## Get Started

To get started please run this command

```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/FirzenYogesh/development-kit/master/install.sh)"
```

Once it is installed, you can install your favorite dependency by executing this command

```
$ development-kit install TOOL_NAME
```

Where `TOOL_NAME` is the tool/dependency you want to install

examples

```
$ development-kit install zsh
$ development-kit install nvm
$ development-kit install docker
```
