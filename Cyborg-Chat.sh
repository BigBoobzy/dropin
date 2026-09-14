#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/Cyborg-Chat"

[ -x "$drop/bin/cybc" ] && { echo "$drop/bin/cybc"; exit 0; }

fish=$("$(dirname "$0")/fish.sh")

rm -rf "$drop"
mkdir -p "$drop/bin"

command -v git >/dev/null || { echo "dropin/Cyborg-Chat  💥 git est requis" >&2; exit 1; }

echo "dropin/Cyborg-Chat  clonage de 6Cyborg-Chat" >&2
git clone -q kmoliybnz@app04.nf.seedbox.io:git/6Cyborg-Chat.git "$drop/repo" >&2

# cybc et ses cgi/*.fish sont des scripts fish qui attendent les fonctions et
# CYBC_HOME définis par cybc-activate.fish : le wrapper source ce fichier
# (fish -C) et met fish dans le PATH pour les shebangs des cgi.
cat > "$drop/bin/cybc" <<EOF
#!/bin/sh
export PATH='${fish%/*}':"\$PATH"
exec '$fish' -C "source '$drop/repo/Cybc-Client/cybc-activate.fish'" '$drop/repo/Cybc-Client/bin/cybc' "\$@"
EOF
chmod +x "$drop/bin/cybc"

[ -x "$drop/bin/cybc" ] || { echo "NOTFOUND: $drop/bin/cybc" >&2; exit 1; }
echo "$drop/bin/cybc"
