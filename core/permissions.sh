#!/bin/bash

function calculateChmodNumber(){

  options=(
      1 'Read' off
      2 'Write' off
      3 'Execution' off
  )
  permissionsSelected=$(createCheckListMenuDialog "Permissions for $1" "${options[@]}")

  calculatedResult=0
  for value in $permissionsSelected; do

    if [ $value = "1" ]
    then
      calculatedResult=`expr $calculatedResult + 1`
    fi

    if [ $value = "2" ]
    then
      calculatedResult=`expr $calculatedResult + 2`
    fi

    if [ $value = "3" ]
    then
      calculatedResult=`expr $calculatedResult + 4`
    fi

  done

  echo "$calculatedResult"
}


function permissions(){

	userPerm=$(calculateChmodNumber "owner user")
	groupPerm=$(calculateChmodNumber "group")
	otherUsersPerm=$(calculateChmodNumber "other users")

  resultPerm=$userPerm$groupPerm$otherUsersPerm
	chmod $resultPerm $1
}