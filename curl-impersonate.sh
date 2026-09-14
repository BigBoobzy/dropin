#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/curl-impersonate"

[ -x "$drop/bin/curl-impersonate-chrome" ] && { echo "$drop/bin/curl-impersonate-chrome"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Le nom de l'archive contient la version : on lit le tag dans la redirection de /releases/latest.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/lwthiker/curl-impersonate/releases/latest)
tag=${tag##*/}

# L'archive est plate : binaires et wrappers curl_* côte à côte, les wrappers cherchent le binaire dans leur propre dossier.
echo "dropin/curl-impersonate  téléchargement de curl-impersonate $tag" >&2
curl -fsSL "https://github.com/lwthiker/curl-impersonate/releases/download/$tag/curl-impersonate-$tag.x86_64-linux-gnu.tar.gz" \
    | tar -xz -C "$drop/bin"
chmod +x "$drop"/bin/*

[ -x "$drop/bin/curl-impersonate-chrome" ] || { echo "NOTFOUND: $drop/bin/curl-impersonate-chrome" >&2; exit 1; }
echo "$drop/bin/curl-impersonate-chrome"
