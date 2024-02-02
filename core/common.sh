#!/bin/bash

# only used for debugging
function pause(){
   read -p 'Press [Enter] key to continue...' -t 3
}

function passwordDialog(){

  password=$(dialog --title "Login" --clear --passwordbox "Enter your user password:" 10 30 2>&1 >/dev/tty)
	echo "$password"

}

function createPwdDialog() {
  password=$(passwordDialog)
  if test -z "$password"; then
      showConfirmationDialog "Operation Cancelled, you will exit from Navex"
      exit 1
  fi

  echo "$password"
}

function showConfirmationDialog(){
    local message="$1"
    dialog --yesno "$message" 0 0
}

function showIncorrectOptDialog(){
  dialog --msgbox "Incorrect option" 10 30
}

function showMsgDialog(){
   local message="$1"
  dialog --msgbox "$message" 0 0
}

function createDialogMenu(){
    local message="$1"
    shift # discard first parameter
    local options=("$@")
    local options_list=("${options[@]}")

    # show custom menu
    local optSelected
    optSelected=$(dialog --menu "$message" 0 0 0 "${options_list[@]}" 2>&1 >/dev/tty)

    echo "$optSelected"
}

function createInputBoxDialog(){
  local title=$1
  local boxMessage=$2

  result=$(dialog --title "$title" \
      --inputbox "$boxMessage" 8 50 2>&1 >/dev/tty)

  echo "$result"
}

function createCheckListMenuDialog() {
    local title="$1"
    shift
    local options=("$@")
    local optSelected

    optSelected=$(dialog --title "$title" --checklist "Select with [Space Bar] " 15 40 5 "${options[@]}" 2>&1 >/dev/tty)

    echo "$optSelected"
}

function obtainUserNameFromPosition() {
  local userPosition="$1"
  local list="$2"

  if test -z "$list"; then
    userName=$(awk -F: '{print $1}' /etc/passwd | awk -v num=$userPosition 'NR == num {print}')
  else
    userName=$(obtainItemNameFromPosition "$userPosition" "$list")
  fi

  echo "$userName"
}

function obtainItemNameFromPosition() {
  local position="$1"
  local list="$2"
  itemName=$(echo "$list" | awk -F. '{print $1}' | awk -v num=$position 'NR == num {print $2}')
  echo "$itemName"
}