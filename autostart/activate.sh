# À sourcer :  . ~/dropin/autostart/activate.sh
# Depuis fish : set -gx PATH (sh -c '. ~/dropin/autostart/activate.sh && printf %s "$PATH"' | string split :)
# Activer un outil : ln -s ../skopeo.sh ~/dropin/autostart/
# Le nom du symlink est passé en $1 : ln -s ../go-3rd.sh ~/dropin/autostart/httpx.sh

for __dropin_s in "${DROPIN_ROOT:-$HOME/dropin}"/autostart/*.sh; do
    case $__dropin_s in */activate.sh) continue ;; esac
    [ -e "$__dropin_s" ] || continue
    __dropin_n=${__dropin_s##*/}
    # les installeurs se localisent par $0 : on exécute la cible du symlink
    if __dropin_p=$("$(readlink -f "$__dropin_s")" "${__dropin_n%.sh}"); then
        __dropin_p=${__dropin_p%/*}
        case ":$PATH:" in
            *":$__dropin_p:"*) ;;
            *) PATH="$PATH:$__dropin_p" ;;
        esac
    fi
done
export PATH
unset __dropin_s __dropin_p
