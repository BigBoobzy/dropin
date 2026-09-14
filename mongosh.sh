#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/mongosh"

[ -x "$drop/bin/mongosh" ] && { echo "$drop/bin/mongosh"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Le nom de l'archive contient la version sans « v » alors que le tag en a un.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/mongodb-js/mongosh/releases/latest)
tag=${tag##*/}
ver=${tag#v}

# L'archive contient déjà bin/mongosh et bin/mongosh_crypt_v1.so (à laisser à côté du binaire).
echo "dropin/mongosh  téléchargement de mongosh $ver" >&2
curl -fsSL "https://github.com/mongodb-js/mongosh/releases/download/$tag/mongosh-$ver-linux-x64.tgz" \
    | tar -xz -C "$drop" --strip-components=1

[ -x "$drop/bin/mongosh" ] || { echo "NOTFOUND: $drop/bin/mongosh" >&2; exit 1; }
echo "$drop/bin/mongosh"
