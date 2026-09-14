#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/skopeo"

[ -x "$drop/bin/skopeo" ] && { echo "$drop/bin/skopeo"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin" "$drop/libexec" "$drop/etc"

# Pas de binaire upstream (containers/skopeo ne publie que des sources).
# lework/skopeo-binary recompile chaque release en statique (CGO_ENABLED=0,
# OpenPGP pur Go), même tag que l'upstream. Binaire nu, pas d'archive.
tag=$(curl -fsSLo /dev/null -w '%{url_effective}' https://github.com/lework/skopeo-binary/releases/latest)
tag=${tag##*/}

echo "dropin/skopeo  téléchargement de skopeo $tag" >&2
curl -fsSL "https://github.com/lework/skopeo-binary/releases/download/$tag/skopeo-linux-amd64" \
    -o "$drop/libexec/skopeo"
chmod +x "$drop/libexec/skopeo"

# skopeo exige policy.json et registries.conf (normalement dans /etc ou
# ~/.config/containers) : le wrapper le pointe sur ceux du drop.
echo '{ "default": [ { "type": "insecureAcceptAnything" } ] }' > "$drop/etc/policy.json"
echo 'unqualified-search-registries = ["docker.io"]' > "$drop/etc/registries.conf"

cat > "$drop/bin/skopeo" <<EOF
#!/bin/sh
export CONTAINERS_REGISTRIES_CONF='$drop/etc/registries.conf'
exec '$drop/libexec/skopeo' --policy '$drop/etc/policy.json' "\$@"
EOF
chmod +x "$drop/bin/skopeo"

mkdir -p "$drop/complete"
"$drop/bin/skopeo" completion fish > "$drop/complete/skopeo.fish"

[ -x "$drop/bin/skopeo" ] || { echo "NOTFOUND: $drop/bin/skopeo" >&2; exit 1; }
echo "$drop/bin/skopeo"
