#!/usr/bin/env bash

SPOTCTL="/home/tuaminx/Bin/spotctl"

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
cd $PANE_PATH

function time_to_sec() {
  TIME=$1
  S=${TIME##*:}
  M=${TIME%%:*}
  TIME_S=$((M*60+S))
  echo $TIME_S
}

function repeat_char() {
  chr=$1
  num=$2
  for i in $(seq 1 $num); do
    printf $chr
  done
}

spotify_status() {

  local STR_STATUS="Spotify is currently "
  local STR_ARTIST="Artist: "
  local STR_TRACK="Track: "
  local STR_POSITION="Position: "

  local SIFS=$IFS
  IFS=$'\n'
  for line in $($SPOTCTL status); do
    line=${line/#Spoitfy/Spotify}
    line=${line%%.}
    if [[ `expr match "$line" "$STR_STATUS"` == 21 ]]; then
      local STATUS=${line##$STR_STATUS}
      local STATUS=${STATUS%% *}
      local PLAYING_DEV=${line##*on }
      continue
    fi
    if [[ `expr match "$line" "$STR_ARTIST"` == 8 ]]; then
      local ARTIST=${line##$STR_ARTIST}
      continue
    fi
    if [[ `expr match "$line" "$STR_TRACK"` == 7 ]]; then
      local TRACK=${line##$STR_TRACK}
      continue
    fi
    if [[ `expr match "$line" "$STR_POSITION"` == 10 ]]; then
      local POSITION=${line##$STR_POSITION}
      local CUR=${POSITION%% / *}
      local END=${POSITION##* / }
      local CUR_S=$(time_to_sec $CUR)
      local END_S=$(time_to_sec $END)
      if [[ "$((END_S-CUR_S))" -lt "10" ]]; then
        local PERC=10
      else
        local PERC=$((CUR_S*10/END_S))
      fi
      local REST=$((10-PERC))
      local PROC="$(repeat_char '◼' $PERC)$(repeat_char '◻' $REST)"
      continue
    fi
  done
  IFS=$SIFS

  local status=""
  if [[ "$STATUS" == "playing" ]]; then
    status="🎶$TRACK $PROC"
  elif [[ "$STATUS" == "paused" ]]; then
    status="⏸ "
  fi

  if [[ -n $status ]]; then
    printf "$status"
  fi
}

main() {
  spotify_status
}

main
