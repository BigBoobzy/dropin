#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/Cyborg-Web"

[ -x "$drop/bin/cybw" ] && { echo "$drop/bin/cybw"; exit 0; }

fish=$("$(dirname "$0")/fish.sh")

rm -rf "$drop"
mkdir -p "$drop/bin"

command -v git >/dev/null || { echo "dropin/Cyborg-Web  💥 git est requis" >&2; exit 1; }

echo "dropin/Cyborg-Web  clonage de 6Cyborg-Web" >&2
git clone -q kmoliybnz@app04.nf.seedbox.io:git/6Cyborg-Web.git "$drop/repo" >&2

# cybw et ses cgi sont des scripts fish qui attendent CYBW_HOME défini par
# cybw-cli-activate.fish : le wrapper source ce fichier (fish -C) et met fish
# dans le PATH pour les shebangs des cgi.
cat > "$drop/bin/cybw" <<EOF
#!/bin/sh
export PATH='${fish%/*}':"\$PATH"
exec '$fish' -C "source '$drop/repo/Cybw-Cli/cybw-cli-activate.fish'" '$drop/repo/Cybw-Cli/bin/cybw' "\$@"
EOF
chmod +x "$drop/bin/cybw"

# TODO : Cybw-Local-Gologin utilise Chrome, qui dépend de libs système absentes
# des machines verrouillées. Non porté : intervention manuelle requise.

[ -x "$drop/bin/cybw" ] || { echo "NOTFOUND: $drop/bin/cybw" >&2; exit 1; }
echo "$drop/bin/cybw"
