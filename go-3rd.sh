#!/bin/sh
set -eu
here="$(dirname "$0")"
bin=${1:?usage: go-3rd.sh <binaire>}
drop="$here/.drops/go-3rd"

mod=$(while read -r b src; do [ "$b" = "$bin" ] && { echo "$src"; break; }; done < "$here/go-bins.txt" || true)
[ -n "$mod" ] || { echo "dropin/go-3rd  💥 $bin absent de go-bins.txt" >&2; exit 1; }

[ -x "$drop/bin/$bin" ] && { echo "$drop/bin/$bin"; exit 0; }

go=$("$here/go.sh")

mkdir -p "$drop/bin"
# Caches conservés entre les outils ; pkg/mod est en lecture seule, chmod -R u+w avant un rm -rf du drop.
export GOBIN="$drop/bin" GOPATH="$drop/gopath" GOCACHE="$drop/gocache" CGO_ENABLED=0

echo "dropin/go-3rd  compilation de $bin" >&2
"$go" install "$mod" >&2

[ -x "$drop/bin/$bin" ] || { echo "NOTFOUND: $drop/bin/$bin" >&2; exit 1; }
echo "$drop/bin/$bin"
