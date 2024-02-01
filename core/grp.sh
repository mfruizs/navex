source common.sh
source users.sh

function createNewGroup(){
  group=$(createInputBoxDialog "Group name" "Write name for group")
  password=$(createPwdDialog)

  echo "$password" | sudo -S addgroup "$group"
  dialog --msgbox "Has been successfully created" 10 30
}

function listGroups(){

  results=$(awk -F: '{print $1}' /etc/group | nl)
  if [ -z "$results" ]; then
      dialog --msgbox "No groups found." 5 20
  else
      selectedGrpPos=$(dialog --clear --menu "Groups" 0 0 0 $results 2>&1 >/dev/tty)
      selectedGrp=$(obtainUserNameFromPosition "$selectedGrpPos" "$results")
      modifyGrp "$selectedGrp"
  fi

}

function addUserToGrp(){

  local grp=$1
  userName=$(selectUserFromList)
  password=$(createPwdDialog)

  echo "$password" | sudo -S adduser "$userName" "$grp"
}

function deleteUserFromGrp(){
  local grp=$1

  results=$(getent group "$grp" | awk -F: '{print $4}' | nl)
  userPosition=$(dialog --clear --menu "Users" 0 0 0 $results 2>&1 >/dev/tty)
  userName=$(obtainUserNameFromPosition "$userPosition" "$results")

  if [ -z "$userName" ]; then
        dialog --msgbox "No users found on this group [$grp]" 0 0
  else
    password=$(createPwdDialog)
    echo "$password" | sudo -S gpasswd -d "$userName" "$grp"
  fi
}

function grpUserList(){
  local grp=$1
  results=$(getent group "$grp" | awk -F: '{print $4}' | nl)
   if test -z "$results"; then
    showMsgDialog "No users to display in this group $grp"
  else
    userPosition=$(dialog --clear --menu "Users" 0 0 0 $results 2>&1 >/dev/tty)
    userName=$(obtainItemNameFromPosition "$userPosition" "$results")
    subManagerUser "$userName"
  fi

}

modifyGrp(){
  local grp=$1

  options=(
      0 "Add user"
      1 "Del user"
      2 "User List"
      3 "Exit"
  )
  option=$(createDialogMenu "    .:: Group Menu ::." "${options[@]}")
  case $option in
	#dialog --menu ".::  MENU: Modificacion Grupo  ::." 0 0 0 0 "Agregar Usuario a Grupo" 1 "Quitar Usuario de un Grupo" 2 "Eliminar Grupo" 3 "SALIR" 2>manux

	0) addUserToGrp "$grp" ;;
	1) deleteUserFromGrp "$grp" ;;
	2) grpUserList "$grp" ;;
	3) sal=true
	;;

	*);;
	esac

}

function findGrp() {

  grp=$(createInputBoxDialog "Group name" "Write group name to find")
  results=$(awk -F: '{print $1}' /etc/group | grep -i $grp | nl)
  if test -z "$results"; then
     dialog --msgbox "Grp '$grp' NO exists" 10 30
  else
    grpPosition=$(dialog --clear --menu "Groups" 0 0 0 $results 2>&1 >/dev/tty)
    grpName=$(obtainItemNameFromPosition "$grpPosition" "$results")
    modifyGrp "$grpName"
  fi

}



function deleteGrp(){

  results=$(awk -F: '{print $1}' /etc/group | nl)
  if [ -z "$results" ]; then
      dialog --msgbox "No groups found." 5 20
  else
      selectedGrpPos=$(dialog --clear --menu "Groups" 0 0 0 $results 2>&1 >/dev/tty)
      selectedGrp=$(obtainUserNameFromPosition "$selectedGrpPos" "$results")

      # confirmation menu
      message="Are you sure you want to delete this grp? > $userName"
      showConfirmationDialog "$message"
      confirmation_result=$?

      if [ $confirmation_result -eq 0 ]; then
        password=$(createPwdDialog)
        echo "$password" | sudo -S groupdel "$selectedGrp"
        dialog --msgbox "Has been successfully deleted" 10 30
      else
        dialog --msgbox "Has been cancelled" 10 30
      fi
  fi

}

function groupManager(){

  options=(
      0 "Create"
      1 "List"
      2 "Find"
      3 "Delete!"
      4 "Exit"
  )
  option=$(createDialogMenu "    .:: Group Menu ::." "${options[@]}")
	case $option in

    0) createNewGroup ;;
    1) listGroups ;;
    2) findGrp ;;
    3) deleteGrp ;;
    4) # exit-nothing-to-do
    ;;
    *) showIncorrectOptDialog ;;
	esac

}
