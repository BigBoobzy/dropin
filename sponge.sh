#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/sponge"

[ -x "$drop/bin/sponge" ] && { echo "$drop/bin/sponge"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin" "$drop/src"

command -v cc >/dev/null || { echo "dropin/sponge  💥 cc est requis" >&2; exit 1; }
command -v xz >/dev/null || { echo "dropin/sponge  💥 xz est requis" >&2; exit 1; }

# moreutils (joeyh) ne publie aucun binaire, seulement des sources via le pool
# Debian : on prend la plus haute version listée dans le répertoire du pool.
ver=$(curl -fsSL https://deb.debian.org/debian/pool/main/m/moreutils/ \
    | sed -n 's/.*href="moreutils_\([0-9.]*\)\.orig\.tar\.xz".*/\1/p' \
    | sort -t. -k1,1n -k2,2n -k3,3n | tail -n1)
[ -n "$ver" ] || { echo "dropin/sponge  💥 aucune version trouvée dans le pool Debian" >&2; exit 1; }

echo "dropin/sponge  téléchargement de moreutils $ver" >&2
curl -fsSL "https://deb.debian.org/debian/pool/main/m/moreutils/moreutils_$ver.orig.tar.xz" \
    | xz -d | tar -x -C "$drop/src" --strip-components=1

# sponge.c est autonome (il #include "physmem.c") et ne dépend que de la libc :
# un seul cc suffit. Le Makefile voudrait docbook2x (man) et installe dans /usr.
echo "dropin/sponge  compilation de sponge" >&2
cc -O2 -o "$drop/bin/sponge" "$drop/src/sponge.c" >&2
rm -rf "$drop/src"

[ -x "$drop/bin/sponge" ] || { echo "NOTFOUND: $drop/bin/sponge" >&2; exit 1; }
echo "$drop/bin/sponge"
