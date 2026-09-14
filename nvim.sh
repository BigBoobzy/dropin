#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/nvim"

[ -x "$drop/bin/nvim" ] && { echo "$drop/bin/nvim"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# L'archive contient déjà bin/, lib/ et share/ ; nvim retrouve son runtime
# relativement à son binaire, on garde l'arborescence telle quelle.
echo "dropin/nvim  téléchargement de neovim" >&2
curl -fsSL https://github.com/neovim/neovim-releases/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | tar -xz -C "$drop" --strip-components=1

[ -x "$drop/bin/nvim" ] || { echo "NOTFOUND: $drop/bin/nvim" >&2; exit 1; }
echo "$drop/bin/nvim"
