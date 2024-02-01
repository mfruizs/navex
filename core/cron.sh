#!/bin/bash

source common.sh
source ffop.sh


function showCronTabInfoBanner() {

    local banner="##########################################################################
    # .---------------- minute (0 - 59)
    # |  .------------- hour (0 - 23)
    # |  |  .---------- day of month (1 - 31)
    # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    # |  |  |  |  |
    # *  *  *  *  *  user-name command to be executed
    # V  V  V  V  |
    #########################################################################################
      15 02  *  *  *"

    dialog --msgbox "$banner" 30 70
}

function generateCrontabFileName() {
  local fileName=$1
  local result
  extension=".cron"

  if [[ $fileName != *"$extension" ]]; then
    result="$fileName$extension"
  else
    result=$fileName
  fi

  echo "$result"
}

function crontabBackup() {
  local password=$1

  showConfirmationDialog "Do you want to create a backup from original /etc/cronjob file?"
  confirmation_result=$?

  # option selected
  if [ $confirmation_result -eq 0 ]; then
      currDate=$(date +"%Y%m%d_%H%M%S")
      backupFile=crontab_"${currDate}".bak
      echo "$password" | sudo -S cp /etc/crontab /etc/"$backupFile"
      dialog --msgbox "Backup was successful with name $backupFile" 30 30
  fi

}

function listCurrentUserCrontab() {
  currentUser=$(whoami)
  noData="no crontab for $currentUser"
  results=$(crontab -l -u "$currentUser")

  if [[ "$noData" =~ ${results} ]]; then
      dialog --msgbox "$noData" 5 30
      crontabManager
  else
      dialog --msgbox "$results" 100 100
      crontabManager
  fi
}

function addJob() {

  password=$(createPwdDialog)
  myUser=$(whoami)

  # Ask for backup
  showCronTabInfoBanner
  crontab -e
  crontabManager

  dialog --msgbox "Has been successfully created at /etc/$fileName" 10 30

}

function deleteJob() {
  myUser=$(whoami)

  # confirmation
  showConfirmationDialog "Do you want to delete $myUser jobs?"
  confirmation_result=$?

  # delete
  if [ $confirmation_result -eq 0 ]; then
    crontab -ri -u "$myUser"
  fi


}


function userJobManager() {
  myUser=$(whoami)
  options=(
      0 "List"
      1 "Add"
      2 "Delete!"
      2 "< Back"
  )
  option=$(createDialogMenu "    .:: Jobs Manager ($myUser) ::." "${options[@]}")
  case $option in
      0) listCurrentUserCrontab ;;
      1) addJob ;;
      2) deleteJob ;;
      3) crontabManager ;;
      *) showIncorrectOptDialog ;;
  esac

}

function crontabFileBackupManager() {
  local fileBackupName=$1

  if [ "$fileBackupName" = ".bak" ]
  then
      showMsgDialog "No exist backup"
      crontabBackupManager
  fi

  options=(
      0 "Show Content"
      1 "Recover Backup"
      2 "Delete Backups!"
      3 "< Back"
  )
  option=$(createDialogMenu "    .:: CronTab Backup Manager ::." "${options[@]}")
  case $option in
      0) data=$(cat "$fileBackupName")
         dialog --msgbox "$data" 100 100
         crontabFileBackupManager
      ;;
      1)  password=$(createPwdDialog)
          echo "$password" | sudo -S cp "$fileBackupName" /etc/crontab
      ;;
      2) deleteFileFolder "$fileBackupName" ;;
      3) crontabBackupManager
      ;;
      *) showIncorrectOptDialog ;;
  esac
  crontabBackupManager
}

function listCronTabBackups() {
  results=$(ls -a /etc/crontab*.bak | nl)
  filePos=$(dialog --clear --menu "CronTabs Backups" 0 0 0 $results 2>&1 >/dev/tty)
  fileSelected=$(obtainItemNameFromPosition "$filePos" "$results")
  crontabFileBackupManager "$fileSelected.bak"
}

function crontabBackupManager() {
    options=(
        0 "Create Backup"
        1 "List Backups"
        2 "< Back"
    )
    option=$(createDialogMenu "    .:: CronTab Manager ::." "${options[@]}")
    case $option in
        0) password=$(createPwdDialog)
          crontabBackup "$password"
        ;;
        1) listCronTabBackups ;;
        2) crontabManager
        ;;
        *) showIncorrectOptDialog ;;
    esac
}

function crontabManager() {
    myUser=$(whoami)
    options=(
        0 "Show Content: (/etc/crontab)"
        1 "Jobs Manager : ($myUser)"
        2 "Crontab Backups (/etc/crontab)"
        3 "< Back"
    )
    option=$(createDialogMenu "    .:: Cron Manager ::." "${options[@]}")
    case $option in
        0) data=$(cat /etc/crontab)
          dialog --msgbox "$data" 100 100
          crontabManager
        ;;
        1) userJobManager ;;
        2) crontabBackupManager ;;
        3) cronJob ;;
        *) showIncorrectOptDialog ;;
    esac

}

function cronJob() {

  options=(
      0 "Crontab Manager"
      1 "Job Manager"
      2 "Exit"
  )
  option=$(createDialogMenu "    .:: Cron Config ::." "${options[@]}")
  case $option in

      0) crontabManager ;;
      1) userJobManager ;;
      2) # exit_nothing-to-do
      ;;
      *) showIncorrectOptDialog ;;
  esac

}