#!/bin/sh
set -eu
drop="$(dirname "$0")/.drops/parallel"

[ -x "$drop/bin/parallel" ] && { echo "$drop/bin/parallel"; exit 0; }

command -v perl >/dev/null || { echo "dropin/parallel  💥 perl est requis" >&2; exit 1; }
command -v bzip2 >/dev/null || { echo "dropin/parallel  💥 bzip2 est requis" >&2; exit 1; }

rm -rf "$drop"
mkdir -p "$drop/bin" "$drop/libexec" "$drop/home" "$drop/share/man/man1" "$drop/share/man/man7" "$drop/tmp"

# GNU parallel n'est pas distribué en binaire : c'est un gros script Perl autonome.
# `./configure && make` ne sert qu'à installer dans /usr/local, on copie `src/` tel quel.
# ftp.gnu.org et ftpmirror.gnu.org sont injoignables depuis certains réseaux : miroir kernel.org.
echo "dropin/parallel  téléchargement de GNU parallel" >&2
curl -fsSL https://mirrors.kernel.org/gnu/parallel/parallel-latest.tar.bz2 \
    | tar -xj -C "$drop/tmp" --strip-components=1

# `src/` mélange exécutables et 7 Mo de doc : on isole ce qui est utile.
mv "$drop/tmp/src/parallel" "$drop/tmp/src/sem" "$drop/tmp/src/parsort" "$drop/libexec/"
mv "$drop/tmp/src/sql" "$drop/tmp/src/niceload" "$drop/tmp/src/parcat" "$drop/tmp/src/parset" \
    "$drop/tmp/src/env_parallel" "$drop/tmp/src/env_parallel.fish" "$drop/bin/"
mv "$drop"/tmp/src/*.1 "$drop/share/man/man1/"
mv "$drop"/tmp/src/*.7 "$drop/share/man/man7/"
rm -rf "$drop/tmp"

# Sans will-cite, parallel réclame une citation académique à chaque lancement
# et écrit dans ~/.parallel : PARALLEL_HOME le confine dans le drop.
# `sem` doit être lancé sous ce nom : parallel se met en mode sémaphore d'après $0.
touch "$drop/home/will-cite"
for name in parallel sem; do
    cat > "$drop/bin/$name" <<EOF
#!/bin/sh
export PARALLEL_HOME='$drop/home'
exec '$drop/libexec/$name' "\$@"
EOF
done

# parsort lance `parallel` par le PATH : on lui garantit le wrapper ci-dessus.
cat > "$drop/bin/parsort" <<EOF
#!/bin/sh
export PATH='$drop/bin':"\$PATH"
exec '$drop/libexec/parsort' "\$@"
EOF

# env_parallel.fish (export des fonctions/variables fish vers les jobs) est à
# sourcer depuis fish, pas à lancer. Toujours l'appeler avec `--env <nom>` :
# sans ça il sérialise TOUT l'environnement sur la ligne de commande et perl
# explose ("argument list too long"). Seules les variables globales sont visibles.
chmod +x "$drop/bin"/* "$drop/libexec"/*

[ -x "$drop/bin/parallel" ] || { echo "NOTFOUND: $drop/bin/parallel" >&2; exit 1; }
echo "$drop/bin/parallel"
