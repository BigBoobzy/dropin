#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/trufflehog"

[ -x "$drop/bin/trufflehog" ] && { echo "$drop/bin/trufflehog"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Le nom de l'archive contient la version sans le « v » du tag.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/trufflesecurity/trufflehog/releases/latest)
tag=${tag##*/}

echo "dropin/trufflehog  téléchargement de trufflehog $tag" >&2
curl -fsSL "https://github.com/trufflesecurity/trufflehog/releases/download/$tag/trufflehog_${tag#v}_linux_amd64.tar.gz" \
    | tar -xz -C "$drop"
mv "$drop/trufflehog" "$drop/bin/trufflehog"

[ -x "$drop/bin/trufflehog" ] || { echo "NOTFOUND: $drop/bin/trufflehog" >&2; exit 1; }
echo "$drop/bin/trufflehog"
