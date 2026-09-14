#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/mongotools"

[ -x "$drop/bin/mongoexport" ] && { echo "$drop/bin/mongoexport"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# mongoexport & Cie ne sont pas packagés par Fedora/Debian (licence SSPL) et
# github.com/mongodb/mongo-tools refuse un `go install` propre (main dans
# `mongoexport/main`, version injectée par `./make build`) : on prend le tarball
# officiel. Variante rhel88 volontaire : glibc 2.28, tourne aussi sur les
# machines distantes anciennes, là où rhel93 exige glibc 2.34.
#
# Pas de release GitHub : la version courante est publiée dans release.json
# (celui de fastdl ; la copie S3 est périmée). On garde la plus haute au cas où
# plusieurs versions y figurent.
url=$(curl -fsSL https://fastdl.mongodb.org/tools/db/release.json \
    | grep -o 'https://[^"]*-rhel88-x86_64-[0-9.]*\.tgz' \
    | sed 's/.*-\([0-9.]*\)\.tgz$/\1 &/' \
    | sort -t. -k1,1n -k2,2n -k3,3n | tail -n1 | cut -d' ' -f2)
[ -n "$url" ] || { echo "dropin/mongotools  aucune archive rhel88-x86_64 dans release.json" >&2; exit 1; }

echo "dropin/mongotools  téléchargement de ${url##*/}" >&2
curl -fsSL "$url" | tar -xz -C "$drop" --strip-components=1

[ -x "$drop/bin/mongoexport" ] || { echo "NOTFOUND: $drop/bin/mongoexport" >&2; exit 1; }
echo "$drop/bin/mongoexport"
