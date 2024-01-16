#!/bin/bash
#
# Download and install dotnet
# https://dotnet.microsoft.com/en-us/download/dotnet/8.0
# Author   : Carl van Heezik
# Revision : 1.0
# Date     : 2023-11-14
# Run script in current shell
# . ./dotnet-sdk-8.0.100

DOTNET_VERSION='8.0.100'
DOTNET_PATH=/usr/local/share/dotnet
DOTNET_SDK_PATH=$DOTNET_PATH/sdk/

MACOS_X86_64_URL=https://download.visualstudio.microsoft.com/download/pr/e59acfc2-5987-43f9-bd03-0cbe446679e1/7db7313c1c99104279a69ccd47d160a1/
MACOS_X86_64_PKG=dotnet-sdk-$DOTNET_VERSION-osx-x64.tar.gz
MACOS_ARM64_URL=https://download.visualstudio.microsoft.com/download/pr/2a79b5ad-82a7-4615-a73b-91bf24028471/0e6a5c6d7f8b792a421e3796a93ef0a1/
MACOS_ARM64_PKG=dotnet-sdk-$DOTNET_VERSION-osx-arm64.tar.gz

LINUX_X86_64_URL=https://download.visualstudio.microsoft.com/download/pr/5226a5fa-8c0b-474f-b79a-8984ad7c5beb/3113ccbf789c9fd29972835f0f334b7a/
LINUX_X86_64_PKG=dotnet-sdk-$DOTNET_VERSION-linux-x64.tar.gz
LINUX_ARM64_URL=https://download.visualstudio.microsoft.com/download/pr/43e09d57-d0f5-4c92-a75a-b16cfd1983a4/cba02bd4f7c92fb59e22a25573d5a550/
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
