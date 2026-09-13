#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/go"

[ -x "$drop/bin/go" ] && { echo "$drop/bin/go"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop"

# Pas de GOROOT : go le déduit de son emplacement. GOPATH/GOBIN/GOCACHE sont
# posés par les installeurs qui compilent, sur leur propre ligne `go install`.
tag=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)

echo "dropin/go  téléchargement de $tag" >&2
curl -fsSL "https://go.dev/dl/$tag.linux-amd64.tar.gz" \
    | tar -xz -C "$drop" --strip-components=1

[ -x "$drop/bin/go" ] || { echo "NOTFOUND: $drop/bin/go" >&2; exit 1; }
echo "$drop/bin/go"
