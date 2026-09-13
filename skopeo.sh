#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/skopeo"

[ -x "$drop/bin/skopeo" ] && { echo "$drop/bin/skopeo"; exit 0; }

go=$("$(dirname "$0")/go.sh")

[ -e "$drop" ] && chmod -R u+w "$drop" # le cache de modules go est en lecture seule
rm -rf "$drop"
mkdir -p "$drop/bin" "$drop/libexec" "$drop/etc"

# Pas de binaire upstream, il faut compiler. Tags de la branche DISABLE_CGO=1
# de leur Makefile : OpenPGP pur Go au lieu de gpgme, pas de headers btrfs.
echo "dropin/skopeo  compilation de skopeo (~2 min)" >&2
GOBIN="$drop/libexec" GOPATH="$drop/gopath" GOCACHE="$drop/gocache" CGO_ENABLED=0 \
    "$go" install -tags "exclude_graphdriver_btrfs containers_image_openpgp" \
    go.podman.io/skopeo/cmd/skopeo@latest >&2
chmod -R u+w "$drop/gopath" "$drop/gocache"
rm -rf "$drop/gopath" "$drop/gocache"

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
