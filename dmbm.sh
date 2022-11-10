#!/bin/bash

# Figure out what conf/bms files should be used
[[ -d "/etc/dmenu_bookmarks" ]] && DMENU_BM="/etc/dmenu_bookmarks"
[[ -d "$HOME/.dmenu_bookmarks" ]] && DMENU_BM="$HOME/.dmenu_bookmarks"
[[ -f "$DMENU_BM/conf" ]] && CONF="$DMENU_BM/conf"
[[ -f "$DMENU_BM/bms" ]] && BMS="$DMENU_BM/bms"

# Ensure the files exist
[[ -z "$DMENU_BM" ]] && echo "ERROR: No dmenu_bookmarks folder (/etc/dmenu_bookmarks or \$HOME/.dmenu_bookmarks)" && exit 1
[[ -z "$CONF" ]] && echo "ERROR: Missing conf file (should be in $DMENU_BM/conf)" && exit 2
[[ -z "$BMS" ]] && echo "ERROR: Missing bms file (should be in $DMENU_BM/bms)" && exit 3

# Read the conf
for line in $(cat $CONF); do
  case "$line" in
    verbose)
      echo "SETTING: Verbose"
      ;;
    *)
      echo "Unknown setting: $line"
      STOP=1
      ;;
  esac
done

# If settings are rubish, stop running
[[ "$STOP" -eq 1 ]] && echo "ERROR: Unknown settings in conf file. Please fix!" && exit 4

# Read the bookmarks and send prompt to dmenu
BOOKMARK="$(cat $BMS | dmenu -l 50 -p 'Select bookmark:')"
xdotool type "$BOOKMARK"
