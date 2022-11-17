#!/bin/bash

# DEFAULT CONFIG
USAGE='dmbm - the browser-independent bookmark manager for dmenu
USAGE:
  dmbm [-r] - select and paste a bookmark with/without return
  dmbm -a   - add a bookmark
  dmbm -e   - edit a bookmark
  dmbm -d   - delete a bookmark
  dmbm -h   - display this help message'
BMS_PATH="$HOME/.local/share/dmbm/bms"
CONF_PATH="$HOME/.config/dmbm/config"
DMBM_USERPATH=''
MAX_DROPDOWN_LENGTH=20

# FUNCTIONS
# Prompt user to select a bookmark, and update the BMS_PATH as well as SELECTION vars
selectBookmark () {
  PROMPT="Select bookmark: BOOKMARKS"
  while [[ -d "$BMS_PATH" ]]; do
    # Find all bookmarks and folders in the current path
    FOLDERS=$(ls --group-directories-first "$BMS_PATH" | head -n -1)
    SINGLES=$(cat "$BMS_PATH/list")

    # Group them together into one array
    BMS=''
    [[ -n "$FOLDERS" ]] && BMS+="$FOLDERS\n"
    BMS+="$SINGLES"

    # Pass it on to dmenu and get the picked bookmark/folder
    SELECTION=$(echo -e "$BMS" | dmenu -i -l "$MAX_DROPDOWN_LENGTH" -p "$PROMPT")

    # If dmenu's return value is empty, the user pressed escape and wants to quit or landed in an empty folder
    [[ -z "$SELECTION" ]] && exit

    # Update the base path to the selected folder/list
    PROMPT+="/$SELECTION"
    BMS_PATH+="/$SELECTION"
  done
}

selectFolder () {
  HEREFOLDER='[save here]'
  PROMPT="Save ($HIGHLIGHT) to BOOKMARKS"
  while [[ ! "$BMS_PATH" =~ "$HEREFOLDER" ]]; do
    # Find all folders
    FOLDERS=$(ls --group-directories-first "$BMS_PATH" | head -n -1)

    # Add the "save here" option to the list
    BMS="$HEREFOLDER\n$FOLDERS"

    # Pass the folders to dmenu and get the picked folder
    SELECTION=$(echo -e "$BMS" | dmenu -i -l "$MAX_DROPDOWN_LENGTH" -p "$PROMPT")

    # Make sure user doesn't want to exit
    [[ -z "$SELECTION" ]] && exit

    # Select folder -> continue, Select [save here] -> break
    [[ "$SELECTION" == "$HEREFOLDER" ]] && BMS_PATH+="/list" && break
    BMS_PATH+="/$SELECTION"
    PROMPT+="/$SELECTION"
  done

  # Append new bookmark to selected list file
  echo "$HIGHLIGHT" >> "$BMS_PATH"
}

# Write the selected bookmark saved in $SELECTION to the active cursor position
writeSelectionToCursor () { xdotool type --delay 0 "$SELECTION"; }
writeReturnToCursor () { xdotool key 'Return'; }

# Get the highlighted text and store it in $HIGHLIGHT
getHighlight () { HIGHLIGHT=$(xclip -o -selection clipboard); }

########
# MAIN #
########

# Source base config
[[ -f '/etc/dmbm/config' ]] && source '/etc/dmbm/config' || exit 1

# Source user config (optional)
[[ -z "$XDG_CONFIG_HOME" ]] \
  && CONF_PATH="$HOME/.config/dmbm/config" \
  || CONF_PATH="$XDG_CONFIG_HOME/dmbm/config"
[[ -f "$CONF_PATH" ]] && source "$CONF_PATH"

# Check if there is a bookmarks folder/create one if needed
[[ ! -d "$BMS_PATH" ]] \
  && mkdir -p "$BMS_PATH" \
  && echo "https://wikipedia.org/Lorem_ipsum" > "$BMS_PATH/list"

# Parse options and do magic
if [[ $# -gt 0 ]]; then
  [[ $# -gt 1 ]] && echo "$USAGE" && exit 3
  case $1 in
    -r)
      DMBM_ENTER=1
      ;;
    -a)
      # Get the highlighted text into the $HIGHLIGHT var
      getHighlight

      # Prompt the user for the folder in which to save the bookmark
      selectFolder
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
      echo "$USAGE" && exit
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

