#!/bin/sh
set -eu
here="$(dirname "$0")"
bin=${1:?usage: node-3rd.sh <binaire>}
# `npm install -g` pose ses shims dans le bin de node, déjà exposé.
gbin="$here/.drops/node/bin"

pkg=$(while read -r b src; do [ "$b" = "$bin" ] && { echo "$src"; break; }; done < "$here/npm-bins.txt" || true)
[ -n "$pkg" ] || { echo "dropin/node-3rd  💥 $bin absent de npm-bins.txt" >&2; exit 1; }

[ -x "$gbin/$bin" ] && { echo "$gbin/$bin"; exit 0; }

node=$("$here/node.sh")
export PATH="${node%/*}:$PATH"

echo "dropin/node-3rd  installation de $pkg" >&2
npm install -g "$pkg" >&2

[ -x "$gbin/$bin" ] || { echo "NOTFOUND: $gbin/$bin" >&2; exit 1; }
echo "$gbin/$bin"
