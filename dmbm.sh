#!/bin/bash

# Source defaults and - if available - user values
[[ -f "/etc/dmenu_bookmarks/conf" ]] && source "/etc/dmenu_bookmarks/conf" || exit 1
[[ -d "/etc/dmenu_bookmarks/bms"  ]] && BMS_PATH="/etc/dmenu_bookmarks/bms" || exit 2
[[ -f "$DMENU_BMS_USER_FOLDER/conf"  ]] && source "/etc/dmenu_bookmarks/conf"
[[ -d "$DMENU_BMS_USER_FOLDER/bms"   ]] && BMS_PATH="$DMENU_BMS_USER_FOLDER/bms"

# Iterate over folders and bookmark lists until the user selects a bookmark
while [[ -d "$BMS_PATH" ]]; do
  FOLDERS=$(ls --group-directories-first "$BMS_PATH" | head -n -1)
  SINGLES=$(cat "$BMS_PATH/list")

  # Newline is needed if there are folders
  if [[ -n "$FOLDERS" ]]; then
    SELECTION=$(printf "$FOLDERS\n$SINGLES" | dmenu -i -l 50 -p 'Select bookmark:')
  else
    SELECTION=$(echo "$SINGLES" | dmenu -i -l 50 -p 'Select bookmark:')
  fi

  # If dmenu's return value is empty, the user pressed escape and wants to quit or landed in an empty folder
  [[ -z "$SELECTION" ]] && exit

  # Update the base path to the selected folder/list
  BMS_PATH="$BMS_PATH/$SELECTION"
done

# Write the bookmark to wherever the user is focused
xdotool type "$SELECTION"
