#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# sync-from-wsl.sh — trae del ENTORNO DE TRABAJO (WSL) al REPO SOLO lo
# que debe quedar versionado, según las convenciones de CLAUDE.md §8.
#
# Se trae:
#   prestashop/themes/vt_autosoe_child/  ->  theme-autosoe/vt_autosoe_child/
#   prestashop/modules/<propios>/        ->  modules-custom/<propios>/
#
# NO se trae (intencionalmente):
#   - el tema padre vt_autosoe ni los módulos comerciales de AutoSoe (licencia)
#   - el core de PrestaShop, img/, var/, cache/
#   - parameters.php (credenciales) ni la base de datos
#
# El script se auto-localiza (REPO sale de su propia ruta), así que mover el
# repo de unidad no lo rompe. Ubicación actual: F:\Gitlab Personal\importtoolsas
# (antes D:\Desarrollo\...), montada en WSL como /mnt/f — ver README §0.bis.
#
# Uso (desde WSL):
#     bash /mnt/f/Gitlab\ Personal/importtoolsas/local-dev/sync-from-wsl.sh
#     bash .../sync-from-wsl.sh --dry-run
#
# Después:  cd al repo y revisar con `git status` / `git diff` antes de commitear.
# ---------------------------------------------------------------------------
set -euo pipefail

LOCAL_DEV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$LOCAL_DEV/.." && pwd)"
SRC="${IT_WSL_DIR:-$HOME/importtools}"

RSYNC_OPTS=(-a --itemize-changes --exclude '.git/' --exclude 'node_modules/')
[ "${1:-}" = "--dry-run" ] && { RSYNC_OPTS+=(--dry-run); echo "*** DRY-RUN: no se escribe nada ***"; }

say() { printf '\n>>> %s\n' "$*"; }

[ -d "$SRC/prestashop" ] || { echo "ERROR: no existe $SRC/prestashop"; exit 1; }

say "Origen : $SRC"
say "Repo   : $REPO"

# --- 1. Tema hijo ----------------------------------------------------------
CHILD="$SRC/prestashop/themes/vt_autosoe_child"
if [ -d "$CHILD" ]; then
    say "tema hijo -> theme-autosoe/vt_autosoe_child/"
    mkdir -p "$REPO/theme-autosoe/vt_autosoe_child"
    rsync "${RSYNC_OPTS[@]}" --delete "$CHILD/" "$REPO/theme-autosoe/vt_autosoe_child/"
else
    say "no hay themes/vt_autosoe_child en WSL — se omite"
fi

# --- 2. Módulos propios ----------------------------------------------------
# Solo se recuperan los módulos que YA existen en modules-custom/, para no
# arrastrar los ~100 módulos de PrestaShop y de AutoSoe.
if compgen -G "$REPO/modules-custom/*/" > /dev/null; then
    say "módulos propios -> modules-custom/"
    for m in "$REPO"/modules-custom/*/; do
        name="$(basename "$m")"
        if [ -d "$SRC/prestashop/modules/$name" ]; then
            rsync "${RSYNC_OPTS[@]}" --delete "$SRC/prestashop/modules/$name/" "$m"
        else
            echo "  (aviso) $name no está en WSL, se omite"
        fi
    done
else
    say "modules-custom/ vacío — nada que traer"
fi

# --- 3. Recordatorio de seguridad -----------------------------------------
say "Revisa antes de commitear:"
cd "$REPO"
git status --porcelain -- theme-autosoe modules-custom | head -40 || true
echo
echo "Recuerda: NO commitear parameters.php, dumps (db/*.sql) ni el .zip del tema."
