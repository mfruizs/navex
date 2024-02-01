#!/bin/bash

source ./core/common.sh
source ./core/ffop.sh
source ./core/users.sh
source ./core/grp.sh
source ./core/cron.sh

function browser() {
  path=$(pwd)
  while true
  do
     browseTo "$path"
  done

}

function mainApplication(){

  while true
  do
    clear
    options=(
        1 "Browser"
        2 "User management"
        3 "Group management"
        4 "Cron-Jobs"
        5 "Exit"
    )
    option=$(createDialogMenu "    .:: Main Menu ::." "${options[@]}")

    case $option in
      1) browser ;;
      2) userManager ;;
      3) groupManager ;;
      4) cronJob ;;
      5) clear
         exit
       ;;
      *) showIncorrectOptDialog ;;
     esac

  done

}

#---------------------- Run application -------------------
mainApplication