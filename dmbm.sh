#!/bin/bash

VERSION='PLACEHOLDERFORVERSION'
USAGE='dmbm - the browser-independent bookmark manager for dmenu
USAGE:
  dmbm [-r] - select and paste a bookmark [with return]
  dmbm -b   - open bookmark with browser
  dmbm -a   - add a bookmark
  dmbm -e   - edit a bookmark
  dmbm -d   - delete a bookmark
  dmbm -h   - display this help message
  dmbm -g   - turn on debugging output'

# Print ${1} if DEBUG is set to true
debug() { [[ $DEBUG -eq true ]] && echo "${1}" ; }

# Print version to STDOUT
exit_with_version() { echo "dmbm v$VERSION" && exit 0 ; }

# Show USAGE and quit gracefully
exit_with_usage() { echo "$USAGE" && exit 0 ; }

# Run a standard dmenu prompt with optional parameters
run_prompted_dmenu() {
  list=${1}
  prompt=${2}
  lines=${3:-20}
  rc=$(echo -e "$list" | dmenu -i -p "$prompt" -l "$lines")
  echo "$rc"
}

# Run a yes/no dmenu prompt
run_yes_no_dmenu() {
  prompt=${1:-"Are you sure?"}
  res=$(run_prompted_dmenu "Yes\nNo" "$prompt" 2)
  [[ "$res" == "Yes" ]] && return 1
  return 0
}

# Initialize BMS and add any folders in the current BMS_PATH to the variable
add_folders_to_bms_list() {
  BMS=''
  FOLDERS=$(ls --group-directories-first "$BMS_PATH" | head -n -1)
  [[ -n "$FOLDERS" ]] && BMS="$FOLDERS\n"
}

# Append any single bookmarks in the current BMS_PATH to BMS
add_singles_to_bms_list() {
  # Throw all rows into a variable
  SINGLES=$(cat "$BMS_PATH/list")
  declare -a singles_for_bms

  # Parse each line
  readarray -d "\n" -t singles_arr <<< "$SINGLES"
  for line in "${singles_arr[@]}"; do
    readarray -d "|" -t l <<< "$line"
    #echo "${l[0]}"
    #echo "${l[1]}"
  done
  
  BMS="$BMS""$SINGLES"
}

# Prompt user to select a bookmark, starting at BMS_BASE
select_bookmark() {
  BMS_PATH="$BMS_BASE"
  while :
  do
    add_folders_to_bms_list
    add_singles_to_bms_list
    
    SELECTION=$(run_prompted_dmenu "$BMS" "$PROMPT" "$MAX_DROPDOWN_LENGTH")
    [[ -z "$SELECTION" ]] && exit 0
    [[ ! -d "$BMS_PATH/$SELECTION" ]] && break
    PROMPT="$PROMPT/$SELECTION"
    BMS_PATH="$BMS_PATH/$SELECTION"
  done

  readarray -d "|" -t arr <<< "$SELECTION"
  SELECTION_NAME=${arr[0]}
  SELECTION_URL=${arr[1]}
}

# Prompt user to pick a bookmark, then ask under what name it should be saved, and if the url should be changed
edit_bookmark() {
  PROMPT="Select bookmark to edit: BMS"
  select_bookmark
  old_row="$SELECTION"

  # Make sure the new name is not empty before continuing
  new_name=$(run_prompted_dmenu "$SELECTION_NAME" "Editing name for bookmark: $SELECTION_NAME" 0)
  [[ -z $new_name ]] && exit

  # Make sure the URL is not empty before continuing
  new_url=$(run_prompted_dmenu "$SELECTION_URL" "Editing URL for bookmark: $SELECTION_URL" 0)
  [[ -z $new_url ]] && exit

  # Output some info for debugging
  debug "New name: $new_name"
  debug "New URL: $new_url"

  # Replace bookmark in-file
  sed -i "s!$old_row!$new_name\|$new_url!g" "$BMS_PATH/list"
}

# Prompt user to select a bookmark, starting at BMS_BASE and then delete it
delete_bookmark() {
  PROMPT="Delete bookmark: BMS"
  select_bookmark
  rc=run_yes_no_dmenu "Are you sure you want to delete the following bookmark? $SELECTION"
  [[ $rc ]] && echo "TODO"
}

# Write the selected bookmark saved in $SELECTION to the active cursor position
write_selection_to_cursor() { xdotool type --delay 0 "$SELECTION_URL"; }
write_return_to_cursor() { xdotool key 'Return'; }

# Launch browser
open_selection_with_browser() { $BROWSER "$SELECTION_URL" ; }

#############
# DMBM MAIN #
#############

# Import standard config from /etc/dmbm/config
[[ -f '/etc/dmbm/config' ]] && source '/etc/dmbm/config' || exit 1

# Import user config from $USER_CONF (sourced from default config)
[[ -f "$USER_CONF" ]] && source "$USER_CONF"

# Process options passed in ARGV
if [[ $# -gt 0 ]]; then
  [[ $# -gt 1 ]] && echo "$USAGE" && exit 3
  case $1 in
    -v) exit_with_version ;;
    -r) APPEND_RETURN=true ;;
    -b) OPEN_BROWSER=true ;;
    -d) delete_bookmark; exit 0 ;;
    -a) get_highlight; select_folder ;;
    -e) edit_bookmark; exit 0 ;;
    -h) exit_with_usage ;;
    *) echo "dmbm.sh: Unknown option ($1)" && exit 4 ;;
  esac
fi

# Check if there is a bookmarks folder/create one if needed
[[ ! -d "$BMS_BASE" ]] \
  && mkdir -p "$BMS_BASE" \
  && echo "https://github.com/cyberme0w/dmbm" > "$BMS_BASE/list"

# Nothing caused the script to exit - run dmbm normally
PROMPT="Select a bookmark: BMS"
select_bookmark
if [[ $OPEN_BROWSER == true ]]; then
  open_selection_with_browser
else
  write_selection_to_cursor
fi

