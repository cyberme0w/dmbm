#!/bin/bash

# FUNCTIONS
# Print usage and exit with success
usage () {
  printf '%s\n' \
         "dmbm - v$DMBM_VERS - conf file @ \"$DMBM_USERPATH\"" \
         '' \
         'USAGE:' \
         '  dmbm [--append-return]   - paste a bookmark to the current cursor position with/without a finishing Return' \
         '  dmbm -a - add a bookmark' \
         '  dmbm -e - edit a bookmark' \
         '  dmbm -d - delete a bookmark' \
         '  dmbm -h - display this help message' \
         'OPTIONS:' \
         '  '
         '' \
         '(press Escape or Enter to close)' #| tee >(dmenu -l "$DMBM_LINES" >> /dev/null)
  return 0
}

# Prompt user to select a bookmark, and update the BMS_PATH as well as SELECTION vars
selectBookmark () {
  while [[ -d "$BMS_PATH" ]]; do
    FOLDERS=$(ls --group-directories-first "$BMS_PATH" | head -n -1)
    SINGLES=$(cat "$BMS_PATH/list")

    # Newline is needed if there are folders
    if [[ -n "$FOLDERS" ]]; then
      SELECTION=$(printf "$FOLDERS\n$SINGLES" | dmenu -i -l "$DMBM_LINES" -p "$DMBM_PROMPT")
    else
      SELECTION=$(echo "$SINGLES" | dmenu -i -l "$DMBM_LINES" -p "$DMBM_PROMPT")
    fi

    # If dmenu's return value is empty, the user pressed escape and wants to quit or landed in an empty folder
    [[ -z "$SELECTION" ]] && exit

    # Update the base path to the selected folder/list
    BMS_PATH="$BMS_PATH/$SELECTION"
  done
}

# Write the selected bookmark saved in $SELECTION to the active cursor position
writeSelectionToCursor () { xdotool type --delay 0 "$SELECTION"; }
writeReturnToCursor () { xdotool key 'Return'; }

# MAIN
# Source defaults and - if available - user values
[[ -f "/etc/dmbm/conf" ]] && source "/etc/dmbm/conf" || exit 1
[[ -d "/etc/dmbm/bms"  ]] && BMS_PATH="/etc/dmbm/bms" || exit 2
[[ -f "$DMBM_USERPATH/conf"  ]] && source "$DMBM_USERPATH/conf"
[[ -d "$DMBM_USERPATH/bms"   ]] && BMS_PATH="$DMBM_USERPATH/bms"

# Parse options and do magic
if [[ $# -gt 0 ]]; then
  [[ $# -gt 1 ]] && usage && exit 3
  case $1 in
    --append-return)
      DMBM_ENTER=1
      ;;
    -a)
      echo "TODO: -a" && exit
      ;;
    -e)
      echo "TODO: -e" && exit
      ;;
    -d)
      echo "TODO: -d" && exit
      ;;
    -f)
      echo "TODO: -f" && exit
      ;;
    -h)
      usage && exit
      ;;
    *)
      echo "dmbm.sh: Unknown option ($1)" && exit 4
      ;;
  esac
fi

# Still here? No options exited yet, so run dmbm normally
selectBookmark
writeSelectionToCursor
[[ $DMBM_ENTER -eq 1 ]] && sleep 0.1 && writeReturnToCursor

