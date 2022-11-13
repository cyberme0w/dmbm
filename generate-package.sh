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

# Create necessary folders
VER=0
REV=$(git log --oneline | wc -l)
PKG="dmbm_$VER-$REV"'_all'
mkdir -p "$PKG" "$PKG/DEBIAN" "$PKG/usr/bin" || failCleanAndExit

# Create DEBIAN/control
printf '%s\n' \
  'Package: dmbm' \
  "Version: $VER-$REV" \
  'Architecture: all' \
  'Maintainer: Iúri Archer (cyberme0w@hotmail.com)' \
  'Depends: dmenu (>= 5.0)' \
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

# Update the version saved in the script
sed -i "s/PLACEHOLDERFORVERSION\$/$VER-$REV/g" "dmbm_$VER-$REV"'_all/usr/bin/dmbm'

# Generate .deb file from it
dpkg --build "$PKG"
