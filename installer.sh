#!/bin/bash

function question() {
  local message=$1
  read -rp "$message (Y/n): " response
  response="${response:-y}"
  echo "$response"
}

function show_progress() {
    local pid=$1
    local delay=0.5

    while ps -p "$pid" > /dev/null; do
        echo -n "#"
        sleep $delay
    done

    echo "> Installation completed!"
}

function red_hat_command() {
  local response=$1
  if [[ "$response" == "n" ]]; then
    pkg_manager="yum install"
  else
    pkg_manager="yum install --assumeno"
  fi
  echo "$pkg_manager"
}

function debian_command() {
  local response=$1
  if [[ "$response" == "n" ]]; then
    pkg_manager="apt install"
  else
    pkg_manager="apt install --simulate"
  fi
  echo "$pkg_manager"
}

function mac_command() {
  local response=$1
  if [[ "$response" == "n" ]]; then
    pkg_manager="brew install"
  else
    pkg_manager="brew install -s"
  fi
  echo "$pkg_manager"
}

function install_dependencies() {
  # Determine OS name
  os=$(uname)

  response=$(question "> Do you want to do the installation in simulation mode?")

  echo "> Simulate version: $response"

  if [ "$os" = "Linux" ]; then

    # verify package manager
    if [[ -f /etc/redhat-release ]]; then
      echo "> OS: Redhat"
      pkg_manager=$(red_hat_command "$response")
    elif [[ -f /etc/debian_version ]]; then
      echo "> OS: Debian"
      pkg_manager=$(debian_command "$response")
    fi

    # install dependencies
    $pkg_manager -y dialog finger expect &
    pid=$!

    # show progress bar
    show_progress $pid

  elif [ "$os" = "Darwin" ]; then

    echo "> Mac OSX"
    pkg_manager=$(mac_command "$response")
    $pkg_manager dialog finger expect

  else

    echo "> Unsupported OS"
    exit 1
  fi

  if [[ "$response" == "y" ]]; then
    echo "|| Simulate mode is finished ||"
    exit 1
  fi

}

function delete_unused_files() {

  response=$(question "> Do you want to delete unused data of Navex?")
  if [[ "$response" == "n" ]]; then
    echo "> Cancelled."
  else
    path=$(pwd)
    echo "> Deleting files of $path"
    cd ..
    rm -rf navex
  fi

}

function install_navex() {
  # want to move script ?
  response=$(question "> Do you want to move script to /usr/local/bin/?")

  if [[ "$response" == "n" ]]; then
    echo "> Cancelled."
  else
    echo "moving files to /usr/local/bin/navex"

    if [ ! -d /usr/local/bin/navex ]; then
        mkdir -p /usr/local/bin/navex
    fi

    mv navex.sh /usr/local/bin/navex
    mv core /usr/local/bin/navex

    echo "> adding script to environment PATH"
    if [[ ":$PATH:" != *":/usr/local/bin/navex:"* ]]; then
      export PATH="$PATH:/usr/local/bin/navex"
    fi

    echo "> adding permissions to navex.sh and core"
    chmod +x /usr/local/bin/navex/navex.sh
    chmod +x /usr/local/bin/navex/core
    chmod +x /usr/local/bin/navex/core/*

    delete_unused_files
  fi

}

function uninstall_navex() {

  response=$(question "> Do you want to unInstall navex script from /usr/local/bin/?")
  if [[ "$response" == "n" ]]; then
      echo "> Cancelled."
    else
      echo "> Deleting files of /usr/local/bin/navex"
      rm -rf /usr/local/bin/navex
      echo "> Deleting on PATH"
      if [[ ":$PATH:" == *":/usr/local/bin/navex:"* ]]; then
        export PATH=$(echo $PATH | sed -e "s|:$PATH:/usr/local/bin/navex:|:|")
      fi
    fi
}

function start_process() {

  if [ -e "/usr/local/bin/navex" ]; then
    uninstall_navex
  else
    install_dependencies
    install_navex
  fi
}

# execute main process
start_process