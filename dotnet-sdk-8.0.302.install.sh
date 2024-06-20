#!/bin/bash
#
# Download and install dotnet
# https://dotnet.microsoft.com/en-us/download/dotnet/8.0
# Author   : Carl van Heezik
# Revision : 1.0
# Date     : 2024-06-20
# Run script in current shell
# . ./dotnet-sdk-8.0.302.install.sh

DOTNET_VERSION='8.0.302'
DOTNET_PATH=/usr/local/share/dotnet
DOTNET_SDK_PATH=$DOTNET_PATH/sdk/

MACOS_X86_64_URL=https://download.visualstudio.microsoft.com/download/pr/8893b99f-aca2-4f93-af7b-cf6017cf5f7b/e45804f1d91b9b01ebd5b15a29e9c088/
MACOS_X86_64_PKG=dotnet-sdk-$DOTNET_VERSION-osx-x64.tar.gz
MACOS_ARM64_URL=https://download.visualstudio.microsoft.com/download/pr/9d5ec61f-58b3-412f-a4b7-be8c295b4877/fcd77a3d07f2c2054b86154634402527/
MACOS_ARM64_PKG=dotnet-sdk-$DOTNET_VERSION-osx-arm64.tar.gz

LINUX_X86_64_URL=https://download.visualstudio.microsoft.com/download/pr/dd6ee0c0-6287-4fca-85d0-1023fc52444b/874148c23613c594fc8f711fc0330298/
LINUX_X86_64_PKG=dotnet-sdk-$DOTNET_VERSION-linux-x64.tar.gz
LINUX_ARM64_URL=https://download.visualstudio.microsoft.com/download/pr/ccc923ed-10de-4131-9c65-2a73f51185cb/3c04869af60dc562d81a673b2fb95515/
LINUX_ARM64_PKG=dotnet-sdk-$DOTNET_VERSION-linux-arm64.tar.gz

install_homebrew()
{
  which -s brew
  if [[ $? != 0 ]]  
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    case $CPU in
    'x86_64')
      (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.zprofile
      eval "$(/usr/local/bin/brew shellenv)"      
      ;;
    'aarch64')
      (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"      
      ;;
    'arm64')
      (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"            
      ;;
    esac
    brew update
    brew install --cask visual-studio-code
  fi
  echo "Update homebrew"
  brew update
}

brew_install()
{
  which -s $1
  if [[ $? != 0 ]]
  then
    brew install $1
  fi
}

download()
{
  URL=$1
  PACKAGE=$2
  if test -f "$PACKAGE"; then
    echo "$PACKAGE downloaded OK"
  else
    echo "Download $PACKAGE"
    wget $URL$PACKAGE
  fi
}

prerequisites_mac_x86_64() 
{
  echo "Installing prerequisites for macOS x86_64"

  if [ -d "$DOTNET_SDK_PATH$DOTNET_VERSION" ]
  then
    echo "Found dotnet SDK $DOTNET_VERSION OK"
  else 
    download $MACOS_X86_64_URL $MACOS_X86_64_PKG
    sudo mkdir -p $DOTNET_PATH
    sudo tar -xzf $MACOS_X86_64_PKG -C $DOTNET_PATH
  fi
}

prerequisites_mac_arm64() 
{
  echo "Installing prerequisites for macOS arm64"

  if [ -d "$DOTNET_SDK_PATH$DOTNET_VERSION" ]
  then
    echo "Found dotnet SDK $DOTNET_VERSION OK"
  else 
    download $MACOS_ARM64_URL $MACOS_ARM64_PKG
    sudo mkdir -p $DOTNET_PATH
    sudo tar -xzf $MACOS_ARM64_PKG -C $DOTNET_PATH
  fi
}

# In zsh the PATH environment variable contains the paths from the following file / directory 
# /etc/paths
# /etc/paths.d
# This script adds the needed path in ~/.zshrc or ~/.bashrc
add_path() 
{
  SCRIPT=$1
  ADD_PATH=$2
  if [[ "$PATH" != *"$ADD_PATH"* ]]
  then
    echo "export PATH=$ADD_PATH:\$PATH" >> $SCRIPT
    . $SCRIPT
  fi
}

set_env() 
{
  SCRIPT=$1
  NAME=$2
  OLD_VALUE=$3
  NEW_VALUE=$4

  if [[ "$OLD_VALUE" != "$NEW_VALUE" ]]
  then
    export $NAME=$NEW_VALUE
    echo "export $NAME=$NEW_VALUE" >> $SCRIPT
  fi
}

prerequisites_mac() 
{
  echo "Detected macOS $CPU"

  install_homebrew
  brew_install wget 
  brew_install pv
  brew_install git-lfs
  git lfs install
  
  echo 
  case $CPU in
  'x86_64')    prerequisites_mac_x86_64 ;;
  'aarch64')   prerequisites_mac_arm64  ;;
  'arm64')   prerequisites_mac_arm64  ;;
  esac
  SCRIPT=~/.zshrc
  add_path "$SCRIPT" "$DOTNET_PATH"
  set_env "$SCRIPT" "DOTNET_ROOT" "$DOTNET_ROOT" "$DOTNET_PATH"
}

prerequisites_linux_x86_64() 
{
  echo "Installing prerequisites for Linux x86_64"

  if [ -d "$DOTNET_SDK_PATH$DOTNET_VERSION" ]
  then
    echo "Found dotnet SDK $DOTNET_VERSION OK"
  else 
    download $LINUX_X86_64_URL $LINUX_X86_64_PKG
    sudo mkdir -p $DOTNET_PATH
    sudo tar -xzf $LINUX_X86_64_PKG -C $DOTNET_PATH
  fi
}

prerequisites_linux_arm64() 
{
  echo "Installing prerequisites for Linux aarch64"

  if [ -d "$DOTNET_SDK_PATH$DOTNET_VERSION" ]
  then
    echo "Found dotnet SDK $DOTNET_VERSION OK"
  else 
    download $LINUX_ARM64_URL $LINUX_ARM64_PKG
    sudo mkdir -p $DOTNET_PATH
    sudo tar -xzf $LINUX_ARM64_PKG -C $DOTNET_PATH
  fi
}

add_path_bash() 
{
  case $PATH in *"$1"*) ;; *) echo "export PATH=$1:\$PATH" >> ~/.bashrc ;; esac
}

set_env_bash() 
{
  NAME=$1
  VALUE=$2
  case $NAME in *"$VALUE"*) ;; *) echo "export $NAME=$VALUE" >> ~/.bashrc ;; esac
}

prerequisites_linux() 
{
  echo "Detected Linux $CPU"

  sudo apt-get -y update
  sudo apt-get -y install sudo
  sudo apt-get -y install wget
  sudo apt-get -y install pv
  sudo apt-get -y install nano
  sudo apt-get -y install libicu-dev
  sudo apt-get -y install git-lfs
  sudo apt-get -y install clang zlib1g-dev
  # comment you may need to change /etc/apt/sources.list
  sudo apt-get install ttf-mscorefonts-installer -y

  case $CPU in
  'x86_64')    prerequisites_linux_x86_64 ;;
  'aarch64')   prerequisites_linux_arm64  ;;
  esac

  SCRIPT=~/.bashrc
  add_path "$SCRIPT" "$DOTNET_PATH"
  set_env "$SCRIPT" "DOTNET_ROOT" "$DOTNET_ROOT" "$DOTNET_PATH"
}

prerequisites() 
{
  KERNEL=$(uname -s)
  CPU=$(uname -m)
  case $KERNEL in
  'Darwin')    prerequisites_mac   ;;
  'Linux')     prerequisites_linux ;;
  esac

  echo "PATH = $PATH"
  echo "DOTNET_ROOT = $DOTNET_ROOT"
  dotnet --list-sdks
}

# Create a temporary directory
mkdir -p tmp
cd tmp
prerequisites
cd ..
