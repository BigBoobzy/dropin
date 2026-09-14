#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/node"

[ -x "$drop/bin/node" ] && { echo "$drop/bin/node"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop"

# Dernière LTS : première ligne de index.tab dont la colonne lts n'est pas « - ».
ver=$(curl -fsSL https://nodejs.org/dist/index.tab | awk 'NR > 1 && $10 != "-" && !found { print $1; found = 1 }')

echo "dropin/node  téléchargement de node $ver" >&2
curl -fsSL "https://nodejs.org/dist/$ver/node-$ver-linux-x64.tar.gz" \
    | tar -xz -C "$drop" --strip-components=1

# Le prefix global de npm est le dossier de node : `npm install -g` pose ses
# shims dans $drop/bin. Ces shims ont un shebang `env node`, d'où le PATH.
export PATH="$drop/bin:$PATH"

# corepack est retiré de la distribution depuis Node 25 : on l'installe depuis
# npm, puis `corepack enable` pose pnpm et yarn dans $drop/bin.
echo "dropin/node  activation de corepack (pnpm, yarn)" >&2
npm install -g --force corepack >&2
corepack enable >&2

[ -x "$drop/bin/node" ] || { echo "NOTFOUND: $drop/bin/node" >&2; exit 1; }
echo "$drop/bin/node"
