#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/rust"

[ -x "$drop/bin/cargo" ] && { echo "$drop/bin/cargo"; exit 0; }
rm -rf "$drop"
mkdir -p "$drop/bin"

export RUSTUP_HOME="$drop/rustup" CARGO_HOME="$drop/cargo"

echo "dropin/rust  installation de rustup et de la toolchain nightly" >&2
curl -fsSL https://sh.rustup.rs > "$drop/rustup-init.sh"
sh "$drop/rustup-init.sh" -y -q --no-modify-path --profile default --default-toolchain nightly >&2

# Les proxys rustup exigent RUSTUP_HOME et CARGO_HOME à chaque exécution :
# un wrapper par proxy les exporte puis exec le vrai binaire.
for real in "$CARGO_HOME"/bin/*; do
    cat > "$drop/bin/$(basename "$real")" <<EOF
#!/bin/sh
export RUSTUP_HOME='$RUSTUP_HOME'
export CARGO_HOME='$CARGO_HOME'
exec '$real' "\$@"
EOF
    chmod +x "$drop/bin/$(basename "$real")"
done

[ -x "$drop/bin/cargo" ] || { echo "NOTFOUND: $drop/bin/cargo" >&2; exit 1; }
echo "$drop/bin/cargo"
