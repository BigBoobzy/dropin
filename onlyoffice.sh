#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/onlyoffice"

[ -x "$drop/bin/OnlyOffice" ] && { echo "$drop/bin/OnlyOffice"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# AppImage nue (plusieurs centaines de Mo), pas d'archive. Nécessite FUSE au lancement.
echo "dropin/onlyoffice  téléchargement de OnlyOffice" >&2
curl -fsSL https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/DesktopEditors-x86_64.AppImage \
    -o "$drop/bin/OnlyOffice"
chmod +x "$drop/bin/OnlyOffice"

[ -x "$drop/bin/OnlyOffice" ] || { echo "NOTFOUND: $drop/bin/OnlyOffice" >&2; exit 1; }
echo "$drop/bin/OnlyOffice"
