#!/usr/bin/env bash

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
cd $PANE_PATH

ROTATION_FILE="/tmp/rotation_tap0.tmp"

rotation() {
  var=0
  if [ -f $ROTATION_FILE ]
  then
    var=$(cat $ROTATION_FILE | head -n1)
    if [ $var == 7 ]
    then
      var=0
    else
      var=$((var+1))
    fi
  fi

  if [ $var == 0 ]
  then
    printf '⣀'
  elif [ $var == 1 ]
  then
    printf '⣤'
  elif [ $var == 2 ]
  then
    printf '⣶'
  elif [ $var == 3 ]
  then
    printf '⣿'
  elif [ $var == 4 ]
  then
    printf '⣶'
  elif [ $var == 5 ]
  then
    printf '⣤'
  else
    printf '⣀'
  fi

  echo $var > $ROTATION_FILE
}

if_status() {
  local status=$(ip addr show dev tap0)

  if [[ -n $status ]]; then
    #printf "$status"
    rotation
  else
   printf "☒"
    #rotation
  fi
}

main() {
  if_status
}

main
