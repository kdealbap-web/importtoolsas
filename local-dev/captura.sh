#!/usr/bin/env bash
# Captura del espejo con Chromium headless.  Uso:
#   ./local-dev/captura.sh <salida.png> <ruta> [ancho] [alto]
# Ej: ./local-dev/captura.sh movil.png / 390 1400
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:?falta el nombre de salida}"
RUTA="${2:-/}"
W="${3:-1280}"
H="${4:-1000}"
DIR="tmp-shots"
mkdir -p "$DIR"

# El espejo redirige al dominio canonico; dentro de la red hay que llamarlo «web»
docker exec it_db mysql -uroot -proot importtools -e "
  UPDATE psjy_shop_url SET domain='web', domain_ssl='web' WHERE id_shop=1;
  UPDATE psjy_configuration SET value='web' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null

restaurar() {
  docker exec it_db mysql -uroot -proot importtools -e "
    UPDATE psjy_shop_url SET domain='localhost:8080', domain_ssl='localhost:8080' WHERE id_shop=1;
    UPDATE psjy_configuration SET value='localhost:8080' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null
}
trap restaurar EXIT

# calentar: la primera peticion tras vaciar cache tarda ~50 s y la captura sale en blanco
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 http://127.0.0.1${RUTA}"

# --headless=old es obligatorio: con el nuevo se cuelga sin escribir el fichero
# MSYS_NO_PATHCONV=1 evita que Git Bash convierta /out en C:/Program Files/Git/out
MSYS_NO_PATHCONV=1 timeout 170 docker run --rm --network importtools_default \
  -v "$(pwd -W 2>/dev/null || pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome --headless=old --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars \
  --virtual-time-budget=9000 --window-size="$W,$H" \
  --screenshot="/out/$OUT" "http://web${RUTA}" 2>&1 | grep -E "bytes written" || echo "  la captura fallo"
