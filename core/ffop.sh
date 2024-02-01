#!/bin/bash

source common.sh
source permissions.sh

function createNewFileFolder(){

  wannaExit=false
  currentPath=$1
  while ! $wannaExit
  do
    clear

    options=(
        0 "File"
        1 "Folder"
        2 "Exit"
    )
    option=$(createDialogMenu "Create New" "${options[@]}")

    case $option in

      0)  wannaExit=true
          newItem=$(createInputBoxDialog "File name" "Write name for the new file")
          touch $currentPath/$newItem
          dialog --msgbox "Has been successfully create: $newItem" 10 30
      ;;

      1)  wannaExit=true
          newItem=$(createInputBoxDialog "Folder name" "Write name for the new folder")
          mkdir $currentPath/$newItem
          dialog --msgbox "Has been successfully create: $newItem" 10 30
      ;;
      2) wannaExit=true ;;
      *)  showIncorrectOptDialog
      ;;
    esac
  done
}

function findFileFolder(){

  # dialog input
  fileNameToFind=$(createInputBoxDialog "File name" "Write a file to find")

  # use command-line
  results=$(find . -type f -name "*$fileNameToFind*" | nl)

   # show results
  if [ -z "$results" ]; then
      dialog --msgbox "No files found." 5 20
  else
      selectedFile=$(dialog --clear --menu "files found" 0 0 0 $results 2>&1 >/dev/tty)
  fi

}

function copyFileFolder(){

  local selected=$1
  local path=$2

  # dialog input
  newFileName=$(createInputBoxDialog "New file name: $selected" "Write new name for this file")

  # use command-line
  results=$(cp -r "$selected" "$path/$newFileName")
  dialog --msgbox "Has been successfully copied to: $newFileName" 10 30
}

function moveFileFolder() {

  local selected=$1
  local path=$2

  # dialog input
  newFileName=$(createInputBoxDialog "New file name/path: $selected" "Write new name/path for this file")

  # use command-line
  results=$(mv "$selected" "$path/$newFileName")
  dialog --msgbox "Has been successfully move/rename to: $path/$newFileName" 10 30

}

function deleteFF() {
  local selected=$1
  if rm -rf "$selected"; then
      dialog --msgbox "Has been successfully deleted" 10 30
  else
      password=$(createPwdDialog)
      echo "$password" | sudo -S rm -rf "$selected"
  fi
}

function deleteFileFolder() {

  local selected=$1

  # Confirmation message
  message="Are you sure you want to delete this file? > $selected"
  showConfirmationDialog "$message"
  confirmation_result=$?

  # option selected
  if [ $confirmation_result -eq 0 ]; then
      deleteFF "$selected"
  else
      dialog --msgbox "Has been cancelled" 10 30
  fi

}

function showOrInstall() {
  local path=$1
  local fileName=$2
  local fileSelected=$path/$fileName

  if [[ $fileName == *".deb" ]]; then
    password=$(createPwdDialog)
    if echo "$password" | sudo -S dpkg -i "$fileSelected"; then
        dialog --msgbox "Has been successfully installed" 10 30
    else
      dialog --msgbox "Error installing package" 10 30
    fi

  else
    data=$(cat "$fileSelected")
    dialog --msgbox "$data" 100 100
  fi

}

function fileMenu(){

  wannaExit=false
  local fileName=$1
  local path=$2
  local fileSelected="$path/$fileName"

  while ! $wannaExit
  do
    clear

    long=`expr length $1`
    newPath=$2

    local zero_option_msg="Show content"
    if [[ $fileName == *".deb" ]]; then
      zero_option_msg="<Install package>"
    fi

    options=(
        0 "$zero_option_msg"
        1 "Delete file!"
        2 "Copy"
        3 "Move/Rename"
        4 "Permissions"
        5 "Exit"
    )

    option=$(createDialogMenu "File options" "${options[@]}")

    case $option in

      0)
          showOrInstall "$path" "$fileName"
      ;;

     1)  wannaExit=true
         deleteFileFolder "$fileSelected"
     ;;
     2)  wannaExit=true
         copyFileFolder "$fileSelected" "$path"
     ;;

     3)  wannaExit=true
         moveFileFolder "$fileSelected" "$path"
     ;;
     4) #PERMISOS
       permissions "$fileSelected"
     ;;
     5) wannaExit=true ;;
     *)  showIncorrectOptDialog
     ;;
    esac

    browseTo $newPath
  done
}

function folderMenu(){

  wannaExit=false
  local selectedFile=$1
  # local folderName=$(basename "$selectedFile")
  local previous_path=$(dirname "$selectedFile")

  while ! $wannaExit
  do
    clear
    options=(
        0 "Create File/Folder"
        1 "Find"
        2 "Copy"
        3 "Move/Rename"
        4 "Delete!"
        5 "Exit"
    )
    option=$(createDialogMenu "Folder options" "${options[@]}")

    case $option in

      0)  wannaExit=true
          createNewFileFolder "$selectedFile"
      ;;

      1)  wannaExit=true
          findFileFolder
      ;;

      2)  wannaExit=true
          copyFileFolder "$selectedFile" "$previous_path"
      ;;

      3)  wannaExit=true
          moveFileFolder "$selectedFile" "$previous_path"
      ;;

      4)  wannaExit=true
          deleteFileFolder "$selectedFile"
      ;;

      5) wannaExit=true
      ;;

      *)  showIncorrectOptDialog
      ;;

    esac

  done
}

#it's a function to browse to current path
function browseTo(){

  unset path
  path=$(realpath "$1")
  upPath=$(realpath cd "$1/..")

  ### ls -a `pwd` | ls -ash1 `pwd`/$i | tail -n +2
  # clear // TODO dejar el clear para tener la pantalla mas limpia
  fileList=$(ls -a $path | ls -ash1 $path/$i | awk '{print $2, $1}' | tail -n +2)
  selectedFile=$(dialog --clear --menu $path 0 0 0 $fileList 2>&1 >/dev/tty)

  #Find it's file or folder
  if [ -d "$path/$selectedFile" ]
  then
    newPath=$path/$selectedFile

    options=(
        0 "Enter ->"
        1 "More actions"
        2 "Go to Main Menu"
    )
    option=$(createDialogMenu "Folder: [ $selectedFile ]" "${options[@]}")
    case $option in
      0) browseTo "$newPath"
      ;;
      1) folderMenu "$newPath" "$upPath"
      ;;
      2) mainApplication
      ;;
      *)	clear
        showIncorrectOptDialog
      ;;
    esac

  elif [ -f "$path/$selectedFile" ]
  then
    #longi=`expr length $path`
    fileMenu "$selectedFile" "$path"
  fi

}