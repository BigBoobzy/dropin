#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/cloudflared"

[ -x "$drop/bin/cloudflared" ] && { echo "$drop/bin/cloudflared"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

# Binaire nu, pas d'archive.
echo "dropin/cloudflared  téléchargement de cloudflared" >&2
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o "$drop/bin/cloudflared"
chmod +x "$drop/bin/cloudflared"

[ -x "$drop/bin/cloudflared" ] || { echo "NOTFOUND: $drop/bin/cloudflared" >&2; exit 1; }
echo "$drop/bin/cloudflared"
