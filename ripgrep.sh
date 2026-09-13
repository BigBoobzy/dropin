#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/ripgrep"

[ -x "$drop/bin/rg" ] && { echo "$drop/bin/rg"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Le nom de l'archive contient la version : on lit le tag dans la redirection de /releases/latest.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/BurntSushi/ripgrep/releases/latest)
tag=${tag##*/}

echo "dropin/ripgrep  téléchargement de ripgrep $tag" >&2
curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/$tag/ripgrep-$tag-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$drop" --strip-components=1
mv "$drop/rg" "$drop/bin/rg"

[ -x "$drop/bin/rg" ] || { echo "NOTFOUND: $drop/bin/rg" >&2; exit 1; }
echo "$drop/bin/rg"
