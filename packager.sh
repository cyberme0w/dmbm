#!/bin/bash
# Script to automatically generate a .deb package of dmbm

# Exit gracefully when shit hits the fan
failCleanAndExit () {
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

cleanAndExit () {
  echo -n "Cleaning up... "
  rm -rf dmbm_*-*_all* && echo "Done!" && exit 0
  echo "Error during cleanup - aborting!"
  exit 1
}

# Check if user just wants to clean
[[ "$1" =~ '--clean' ]] && cleanAndExit

# Create necessary folders
MAJ=0
MIN=1
PATCH=$(git log --oneline | wc -l)
PKG="dmbm_$MAJ.$MIN-$PATCH"'_all'
mkdir -p "$PKG" "$PKG/DEBIAN" "$PKG/usr/bin" "$PKG/etc/dmbm" || failCleanAndExit

# Create DEBIAN/control
printf '%s\n' \
  'Package: dmbm' \
  "Version: $MAJ.$MIN-$PATCH" \
  'Architecture: all' \
  'Maintainer: Iúri Archer (cyberme0w@hotmail.com)' \
  'Depends: suckless-tools (>= 46-2)' \
  'Homepage: https://github.com/cyberme0w/dmbm' \
  'Description: a minimal bookmarking extension for dmenu' \
  '  dmbm is a browser-independent "do-as-little-as-it-should"' \
  '  bookmarking system to be used in conjunction with dmenu.' \
  '  Features include:' \
  '    * Folder support' \
  '    * Add/edit/delete bookmarks directly in the dmenu prompt' \
  '    * Bookmarks are stored in simple flatfiles' > "$PKG/DEBIAN/control" || failCleanAndExit

# Copy stuff over
cp 'dmbm.sh' "$PKG/usr/bin/dmbm" || failCleanAndExit
cp 'config' "$PKG/etc/dmbm/config" || failCleanAndExit

# Update the version saved in the script
sed -i "s/PLACEHOLDERFORVERSION\$/$MAJ.$MIN-$PATCH/g" "dmbm_$MAJ.$MIN-$PATCH"'_all/usr/bin/dmbm'

# Generate .deb file from it
dpkg --build "$PKG"

# Remove generated package folder
[[ ! $1 =~ '--keep' ]] && rm -rf "$PKG"
