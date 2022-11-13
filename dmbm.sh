#!/bin/bash

# DEFAULT CONFIG
DMBM_VERS=PLACEHOLDERFORVERSION
DMBM_LINES=50
DMBM_PROMPT='Select your bookmark:'
DMBM_USERPATH=''

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

# Find user's config path
findUserConfig () {
  # Magic can happen either in the XDG folder or in .config
  if [[ -z "$XDG_CONFIG_HOME" ]]; then
    DMBM_USERPATH="$HOME/.config/dmbm"
  else
    DMBM_USERPATH="$XDG_CONFIG_HOME/dmbm"
  fi
}

# Check if it is the first time the user is running dmbm and set things up
checkFirstTimeRun () {
  # If the dmbm/bms folder already exists, no need to do anything
  [[ -d "$DMBM_USERPATH/bms" ]] && return 0
  
  # Otherwise, generate the dmbm/bms folder with a basic entry
  echo "Generating user folder..."
  mkdir -p "$DMBM_USERPATH/bms"
  echo "https://wikipedia.org/Lorem_ipsum" > "$DMBM_USERPATH/bms/list"
  echo "Done!"
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
# Check if it's the user's first run and if necessary create the folder structure
findUserConfig
checkFirstTimeRun

# Source user config and set starting bms path
[[ -f "$DMBM_USERPATH/conf"  ]] && source "$DMBM_USERPATH/conf"
BMS_PATH="$DMBM_USERPATH/bms"

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

# Still here? No options made the script return, so run dmbm normally
selectBookmark
writeSelectionToCursor
[[ $DMBM_ENTER -eq 1 ]] && sleep 0.1 && writeReturnToCursor

