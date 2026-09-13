# dropin

LA BRANCHE C'EST MASTER PAS MAIN F2P

Installeurs autonomes pour poser une toolchain **sans root et sans gestionnaire
de paquets**, dans `.drops/<outil>/` à côté des scripts. Chaque `<outil>.sh` :

- est idempotent : s'il trouve l'exécutable, il ne fait rien ;
- écrit **uniquement le chemin de l'exécutable sur stdout**, tout le reste sur stderr ;
- se localise par `dirname "$0"` : à appeler par chemin absolu, jamais via un symlink.

Les outils qui ont besoin de variables d'environnement (rust, skopeo) renvoient
un wrapper qui les embarque : rien à exporter côté appelant.

## Usage humain

```sh
git clone <remote> ~/dropin

# activer les outils voulus : un symlink par outil, versionnable
cd ~/dropin && ln -s ../fish.sh ../ripgrep.sh ../skopeo.sh ../rust.sh autostart/

# brancher l'autostart dans le shell de login (une fois)
echo '. ~/dropin/autostart/activate.sh' >> ~/.profile        # sh / bash / zsh
# ou, sous fish, dans ~/.config/fish/config.fish :
#   set -gx PATH (sh -c '. ~/dropin/autostart/activate.sh && printf %s "$PATH"' | string split :)

# sans attendre le prochain login
. ~/dropin/autostart/activate.sh
```

Le premier `source` installe ce qui manque, les suivants ne font que lire.
Ensuite les commandes sont dans le PATH :

```sh
rg TODO src/
skopeo inspect docker://alpine
cargo new demo          # le wrapper pose RUSTUP_HOME/CARGO_HOME lui-même
```

Mettre à jour : supprimer le drop, le prochain `source` réinstalle la dernière
version (rust : `rustup update`). Désinstaller : supprimer le symlink dans
`autostart/` et le drop. Rien n'est écrit ailleurs.

```sh
rm -rf ~/dropin/.drops/ripgrep
```

## Usage dans un script (VM éphémère)

L'autostart n'intervient pas : chaque installeur est appelé par chemin absolu et
renvoie le chemin de son exécutable.

```sh
#!/bin/sh
set -eu
git clone --depth 1 <remote> "$HOME/dropin"

skopeo=$("$HOME/dropin/skopeo.sh")          # installe go puis compile, ~2 min
trufflehog=$("$HOME/dropin/trufflehog.sh")  # télécharge le binaire, quelques secondes

"$skopeo" copy docker://alpine:latest "dir:$HOME/up"
"$trufflehog" filesystem "$HOME/up" --json
```

- Entrypoint en fish : `exec "$("$HOME/dropin/fish.sh")" "$HOME/entry.fish"`, puis
  même contrat dans `entry.fish` : `set skopeo (~/dropin/skopeo.sh)`.
- Un outil qui en appelle un autre par son nom (`git`, `cargo`…) :
  `PATH="$PATH:$(dirname "$cargo")"`, sans sourcer l'autostart.
