#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/mblaze"

[ -x "$drop/bin/mshow" ] && { echo "$drop/bin/mshow"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

command -v git >/dev/null || { echo "dropin/mblaze  💥 git est requis" >&2; exit 1; }
command -v cc >/dev/null || { echo "dropin/mblaze  💥 cc est requis" >&2; exit 1; }
command -v make >/dev/null || { echo "dropin/mblaze  💥 make est requis" >&2; exit 1; }

# Pas de binaire upstream, il faut compiler. La cible install dépend de all.
echo "dropin/mblaze  clonage et compilation de mblaze" >&2
git clone -q --depth 1 https://github.com/leahneukirchen/mblaze "$drop/repo" >&2
make -C "$drop/repo" PREFIX="$drop" install >&2
rm -rf "$drop/repo"

[ -x "$drop/bin/mshow" ] || { echo "NOTFOUND: $drop/bin/mshow" >&2; exit 1; }
echo "$drop/bin/mshow"
