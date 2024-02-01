#!/bin/bash
source common.sh


function addNewUser(){
  password=$(createPwdDialog)
  username=$(createInputBoxDialog "User name" "Write name for the new user")
  exist=$(awk -F: '{print $1}' /etc/passwd | grep -i $username)

  if test -z "$exist"; then
    echo "$password" | sudo -S adduser "$username"
  else
    dialog --msgbox "User '$username' currently exists" 10 30
  fi
}

function findUser() {

  userName=$(createInputBoxDialog "User name" "Write name for the new user")
  results=$(awk -F: '{print $1}' /etc/passwd | grep -i $userName | nl)
  if test -z "$results"; then
     dialog --msgbox "User '$userName' NO exists" 10 30
  else
    userPosition=$(dialog --clear --menu "Users" 0 0 0 $results 2>&1 >/dev/tty)
    userSelected=$(obtainUserNameFromPosition "$userPosition" "$results")
    subManagerUser "$userSelected"
  fi
  userManager

}

function listUsers(){

  results=$(awk -F: '{print $1}' /etc/passwd | nl)
  if [ -z "$results" ]; then
      dialog --msgbox "No users found." 5 20
  else
      selectedUser=$(dialog --clear --menu "Users" 0 0 0 $results 2>&1 >/dev/tty)
      echo $selectedUser
  fi

}

function modUserHomeDirectory() {
  local user=$1

  # get sudo pass
  password=$(createPwdDialog)

  # select new home directory
  home=$(createInputBoxDialog "Home directory" "Write new home directory for $user")

  # execute commands
  echo "$password" | sudo -S adduser "$home"
  echo "$password" | sudo -S usermod -d "$home" "$user"
  dialog --msgbox "Has been successfully change" 10 30

}

function blockUserAccount(){
  local user=$1
  password=$(createPwdDialog)
  echo "$password" | sudo -S usermod -L "$user";
  dialog --msgbox "Has been successfully blocked" 10 30
  modifyUser
}

function unBlockUserAccount(){
  local user=$1
  password=$(createPwdDialog)
  echo "$password" | sudo -S usermod -U "$user";
  dialog --msgbox "Has been successfully blocked" 10 30
  modifyUser
}

function modifyPwdUser(){
  local user=$1
  local appPath=$(pwd)

  pkgInstalled=$(which expect)

  if test -z "$pkgInstalled"; then
        showMsgDialog "Operation Cancelled > You need install 'expect' package to use this option"
        modifyUser
    else
      password=$(createPwdDialog)
      echo "$password" | sudo -S chmod +x pwd.exp

      new_password=$(dialog --title "New Password" --clear --passwordbox "Enter new password for $user:" 10 30 2>&1 >/dev/tty)
      # TODO Under fixing
      "$appPath"/pwd.exp "$user" "$password" "$new_password"
      # echo "$password" | sudo -S passwd "$user";
      # pause
      dialog --msgbox "Password has been successfully changed" 10 30
      modifyUser
    fi

}

function modifyUser(){
  local user=$1
  clear

  options=(
      0 "Change Home directory"
      1 "Block account"
      2 "UnBLock account"
      3 "Modify password"
      4 "Exit"
  )
  option=$(createDialogMenu "More Actions (user: $user)" "${options[@]}")
	case $option in
    0) modUserHomeDirectory "$user" ;;
    1) blockUserAccount "$user" ;;
    2) unBlockUserAccount "$user" ;;
    3) modifyPwdUser "$user" ;;
    4) userManager ;;
	  *) showIncorrectOptDialog ;;
	esac

	userManager

}

function infoUser(){
  local user="$1"
  pkgInstalled=$(apt list --installed 2>/dev/null | grep -i finger)
  if test -z "$pkgInstalled"; then
      showMsgDialog "Operation Cancelled > You need install 'finger' package to use this option"
  else
    info=$(finger "$user")
    showMsgDialog "$info"
  fi
  userManager
}

function selectUserFromList(){

    # obtain and select users
    userPosition=$(listUsers)
    userName=$(obtainUserNameFromPosition "$userPosition")
    echo "$userName"
}


function managerUser() {

    # obtain and select users
    userName=$(selectUserFromList)

    subManagerUser "$userName"

}

function deleteUser(){

  userName="$1"

  # confirmation menu
  message="Are you sure you want to delete this user? > $userName"
  showConfirmationDialog "$message"
  confirmation_result=$?

  if [ $confirmation_result -eq 0 ]; then
    password=$(createPwdDialog)
    echo "$password" | sudo -S userdel "$userName"
    dialog --msgbox "Has been successfully deleted" 10 30
  else
    dialog --msgbox "Has been cancelled" 10 30
  fi
}

function recoverUser(){
  # select new home directory
  userName=$(createInputBoxDialog "User Name" "Write user name to recover")
  group=$(createInputBoxDialog "Group Name" "Write group name for $userName or empty to auto-select")
  if test -z "$group"; then
      group=$userName
  fi
  password=$(createPwdDialog)
  echo "$password" | sudo -S useradd --gid "$group" "$userName"
  dialog --msgbox "Has been successfully restored" 10 30

}

function subManagerUser(){
  local userName=$1

  options=(
      1 "Info"
      2 "More actions"
      3 "Delete!"
      4 "Exit"
  )
  option=$(createDialogMenu "    .:: User Menu ::." "${options[@]}")

  case $option in
    1) infoUser "$userName" ;;
    2) modifyUser "$userName" ;;
    3) deleteUser "$userName" ;;
    4) userManager ;;
    *) showIncorrectOptDialog ;;
  esac

}

function userManager(){

  options=(
      0 "Add"
      1 "Find"
      2 "List"
      3 "Recover"
      4 "Exit"
  )
  option=$(createDialogMenu "    .:: User Menu ::." "${options[@]}")

  case $option in

    0) addNewUser ;;
    1) findUser ;;
    2) managerUser ;;
    3) recoverUser ;;
    4) # exit_nothing-to-do
    ;;
    *) showIncorrectOptDialog ;;
  esac


}