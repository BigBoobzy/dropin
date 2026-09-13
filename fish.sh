#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/fish"

[ -x "$drop/bin/fish" ] && { echo "$drop/bin/fish"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Le nom de l'archive contient la version : on lit le tag dans la redirection de /releases/latest.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/fish-shell/fish-shell/releases/latest)
tag=${tag##*/}

echo "dropin/fish  téléchargement de fish $tag" >&2
curl -fsSL "https://github.com/fish-shell/fish-shell/releases/download/$tag/fish-$tag-linux-x86_64.tar.xz" \
    | tar -xJ -C "$drop/bin"

[ -x "$drop/bin/fish" ] || { echo "NOTFOUND: $drop/bin/fish" >&2; exit 1; }
echo "$drop/bin/fish"
