#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/uv"

[ -x "$drop/bin/uv" ] && { echo "$drop/bin/uv"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

echo "dropin/uv  téléchargement de uv" >&2
curl -fsSL https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz \
    | tar -xz -C "$drop/bin" --strip-components=1

[ -x "$drop/bin/uv" ] || { echo "NOTFOUND: $drop/bin/uv" >&2; exit 1; }
echo "$drop/bin/uv"
