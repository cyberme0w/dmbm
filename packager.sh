#!/bin/bash
# Script to automatically generate a .deb package of dmbm

USAGE='packager.sh
  --help   - print this help message
  --clean  - remove .deb packages and packaged folder structure
  --keep   - after building .deb, do not remove folder structure'

# Exit gracefully when shit hits the fan
fail_clean_and_exit () {
  echo "Something went wrong during packaging!"
  read -r -p "Delete unfinished package($PKG)? (y/N) " YESNO
  if [[ ${YESNO,,} =~ ^(y|yes)$ ]]; then
    echo -n "Deleting $PKG... "
    rm -rf "$PKG"
    echo "Done!"
  fi
  
  echo "Will now exit. Good luck bug hunting!"
  exit 0
}

clean_and_exit () {
  echo -n "Cleaning up... "
  rm -rf dmbm_*-*_all* && echo "Done!" && exit 0
  echo "Error during cleanup - aborting!"
  exit 1
}

exit_with_usage () {
  echo "$USAGE" && exit 0
}

# Check if user wants the help message
[[ "$1" =~ '--help' ]] && exit_with_usage

# Check if user just wants to clean
[[ "$1" =~ '--clean' ]] && clean_and_exit

# Create necessary folders
MAJ=0
MIN=1
PATCH=$(git log --oneline | wc -l)
PKG="dmbm_$MAJ.$MIN-$PATCH"'_all'
mkdir -p "$PKG" "$PKG/DEBIAN" "$PKG/usr/bin" "$PKG/etc/dmbm" || fail_clean_and_exit

# Create DEBIAN/control
printf '%s\n' \
  'Package: dmbm' \
  "Version: $MAJ.$MIN-$PATCH" \
  'Architecture: all' \
  'Maintainer: Iúri Archer (cyberme0w@hotmail.com)' \
  'Depends: suckless-tools (>= 46-2)' \
  'Homepage: https://github.com/cyberme0w/dmbm' \
  'Description: a minimal bookmarking extension for dmenu' \
  '  dmbm is a browser-agnostic bookmarking system for dmenu.' \
  '  Features include:' \
  '    * Structure bookmarks in folders' \
  '    * Add/edit/remove bookmarks directly in the dmenu prompt' \
  '    * Bookmarks are stored in flatfiles' > "$PKG/DEBIAN/control" || fail_clean_and_exit

# Copy stuff over
cp 'dmbm.sh' "$PKG/usr/bin/dmbm" || fail_clean_and_exit
cp 'config' "$PKG/etc/dmbm/config" || fail_clean_and_exit

# Update the version saved in the script
sed -i -e "s/PLACEHOLDERFORVERSION\$/$MAJ.$MIN-$PATCH/g" "dmbm_$MAJ.$MIN-$PATCH"'_all/usr/bin/dmbm'

# Generate .deb file from it
dpkg --build "$PKG"

# Remove generated package folder
[[ ! $1 =~ '--keep' ]] && rm -rf "$PKG"

