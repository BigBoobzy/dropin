#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/aws"

[ -x "$drop/bin/aws" ] && { echo "$drop/bin/aws"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

command -v unzip >/dev/null || { echo "dropin/aws  💥 unzip est requis" >&2; exit 1; }

echo "dropin/aws  téléchargement de awscli" >&2
curl -fsSL -o "$drop/.zip" https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip -q "$drop/.zip" -d "$drop" >&2
rm -f "$drop/.zip"

# Le bundle Python de $drop/aws/dist doit rester intact : on n'expose que des
# symlinks, comme l'installeur officiel le fait vers /usr/local/bin. Cibles
# relatives à $drop/bin, car $drop peut lui-même être un chemin relatif.
ln -s ../aws/dist/aws "$drop/bin/aws"
ln -s ../aws/dist/aws_completer "$drop/bin/aws_completer"

[ -x "$drop/bin/aws" ] || { echo "NOTFOUND: $drop/bin/aws" >&2; exit 1; }
echo "$drop/bin/aws"
