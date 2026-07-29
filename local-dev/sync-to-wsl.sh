#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# sync-to-wsl.sh — empuja del REPO (D:) al ENTORNO DE TRABAJO (ext4 en WSL).
#
# El repo en D: es la fuente de verdad de lo versionado (compose, Dockerfile,
# php.ini, tema hijo, módulos propios). El entorno que Docker realmente sirve
# vive en ~/importtools dentro de WSL, sobre ext4, porque /mnt/d vía 9p hace
# que el back office de PrestaShop tarde decenas de segundos por página.
#
# Uso (desde WSL):
#     bash /mnt/d/Desarrollo/Gitlab\ Personal/importtoolsas/local-dev/sync-to-wsl.sh
#     bash .../sync-to-wsl.sh --dry-run      # solo mostrar qué cambiaría
#
# NO toca la base de datos ni prestashop/var/cache.
# ---------------------------------------------------------------------------
set -euo pipefail

LOCAL_DEV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$LOCAL_DEV/.." && pwd)"
DST="${IT_WSL_DIR:-$HOME/importtools}"
WWW_GID=33                     # www-data en la imagen php:8.5-apache

RSYNC_OPTS=(-a --itemize-changes)
[ "${1:-}" = "--dry-run" ] && { RSYNC_OPTS+=(--dry-run); echo "*** DRY-RUN: no se escribe nada ***"; }

say() { printf '\n>>> %s\n' "$*"; }

[ -d "$DST" ] || { echo "ERROR: no existe $DST — corre primero la copia inicial del entorno."; exit 1; }

say "Repo   : $REPO"
say "Destino: $DST"

# --- 1. Infra del contenedor -----------------------------------------------
say "compose / Dockerfile / config"
rsync "${RSYNC_OPTS[@]}" "$LOCAL_DEV/docker-compose.yml" "$LOCAL_DEV/Dockerfile" "$DST/"
rsync "${RSYNC_OPTS[@]}" --delete "$LOCAL_DEV/config/" "$DST/config/"

# --- 2. Tema hijo ----------------------------------------------------------
# El tema padre (vt_autosoe) viene de producción y NO se versiona; solo el hijo.
if [ -d "$REPO/theme-autosoe/vt_autosoe_child" ]; then
    say "tema hijo -> prestashop/themes/vt_autosoe_child/"
    mkdir -p "$DST/prestashop/themes/vt_autosoe_child"
    rsync "${RSYNC_OPTS[@]}" --delete \
        "$REPO/theme-autosoe/vt_autosoe_child/" \
        "$DST/prestashop/themes/vt_autosoe_child/"
else
    say "sin theme-autosoe/vt_autosoe_child — se omite"
fi

# --- 3. Módulos propios ----------------------------------------------------
if compgen -G "$REPO/modules-custom/*/" > /dev/null; then
    say "módulos propios -> prestashop/modules/"
    for m in "$REPO"/modules-custom/*/; do
        rsync "${RSYNC_OPTS[@]}" --delete "$m" "$DST/prestashop/modules/$(basename "$m")/"
    done
else
    say "sin módulos en modules-custom/ — se omite"
fi

# --- 4. Permisos para www-data --------------------------------------------
if [ "${1:-}" != "--dry-run" ]; then
    say "Reaplicando permisos (kevin:$WWW_GID) sobre lo sincronizado"
    for p in "$DST/prestashop/themes/vt_autosoe_child" "$DST/prestashop/modules"; do
        [ -d "$p" ] || continue
        sudo chown -R "$(id -un):$WWW_GID" "$p"
        sudo find "$p" -type d -exec chmod 2775 {} +
        sudo find "$p" -type f -exec chmod 664 {} +
    done

    say "Limpiando caché de PrestaShop (obligatorio tras tocar tema/módulos)"
    sudo rm -rf "$DST/prestashop/var/cache/"* 2>/dev/null || true
    echo "caché vaciada"
fi

say "LISTO. Si cambió el Dockerfile o php.ini:  cd $DST && docker compose up -d --build"
