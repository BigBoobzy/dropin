#!/bin/sh
set -eu
here="$(dirname "$0")"
bin=${1:?usage: rust-3rd.sh <binaire>}
drop="$here/.drops/rust-3rd"

crate=$(while read -r b src; do [ "$b" = "$bin" ] && { echo "$src"; break; }; done < "$here/rust-bins.txt" || true)
[ -n "$crate" ] || { echo "dropin/rust-3rd  💥 $bin absent de rust-bins.txt" >&2; exit 1; }

[ -x "$drop/bin/$bin" ] && { echo "$drop/bin/$bin"; exit 0; }

cargo=$("$here/rust.sh")

mkdir -p "$drop/bin"

# --root : le binaire va dans $drop/bin, pas dans $CARGO_HOME/bin à côté des proxys rustup.
echo "dropin/rust-3rd  compilation de $bin (plusieurs minutes)" >&2
"$cargo" install --quiet --root "$drop" "$crate" >&2

[ -x "$drop/bin/$bin" ] || { echo "NOTFOUND: $drop/bin/$bin" >&2; exit 1; }
echo "$drop/bin/$bin"
