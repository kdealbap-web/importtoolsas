#!/usr/bin/env bash
# Captura la tienda DESPUES de pulsar un selector (menu movil, buscador...).
#   ./local-dev/interactuar.sh <salida.png> <ruta> <ancho> <alto> <selector a pulsar>
# Ej: ./local-dev/interactuar.sh menu.png / 390 900 .navbar-toggler
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:?falta el nombre de salida}"
RUTA="${2:-/}"
W="${3:-390}"
H="${4:-900}"
CLIC="${5:-}"
DIR="tmp-shots"
mkdir -p "$DIR"
export MSYS_NO_PATHCONV=1

docker exec it_db mysql -uroot -proot importtools -e "
  UPDATE psjy_shop_url SET domain='web', domain_ssl='web' WHERE id_shop=1;
  UPDATE psjy_configuration SET value='web' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null

restaurar() {
  docker exec it_db mysql -uroot -proot importtools -e "
    UPDATE psjy_shop_url SET domain='localhost:8080', domain_ssl='localhost:8080' WHERE id_shop=1;
    UPDATE psjy_configuration SET value='localhost:8080' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null
}
trap restaurar EXIT

docker cp local-dev/_interactuar.html it_web:/var/www/html/_interactuar.html >/dev/null
docker exec it_web sh -c 'chown www-data:www-data /var/www/html/_interactuar.html'
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 'http://127.0.0.1${RUTA}'"

URL="http://web/_interactuar.html?r=${RUTA}&w=${W}&h=${H}&c=${CLIC}"

timeout 200 docker run --rm --network importtools_default \
  -v "$(pwd -W 2>/dev/null || pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome --headless=new --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars \
  --virtual-time-budget=20000 --window-size="$((W + 10)),$H" \
  --screenshot="/out/$OUT" "$URL" 2>&1 | grep -E "bytes written" || echo "  la captura fallo"
