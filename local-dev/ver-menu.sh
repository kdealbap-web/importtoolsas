#!/usr/bin/env bash
# Captura el menú de la cuenta ABIERTO, con o sin sesión iniciada.
#   ./local-dev/ver-menu.sh <salida.png> <ancho> [alto] [correo] [clave] [ruta]
# Ej: ./local-dev/ver-menu.sh menu.png 1440
#     ./local-dev/ver-menu.sh menu-log.png 1440 700 cliente@x.com Clave123
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:?falta el nombre de salida}"
W="${2:-1440}"
H="${3:-700}"
USUARIO="${4:-}"
CLAVE="${5:-}"
RUTA="${6:-/}"
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

docker cp local-dev/_ver-menu.html it_web:/var/www/html/_ver-menu.html >/dev/null
docker exec it_web sh -c 'chown www-data:www-data /var/www/html/_ver-menu.html'
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 'http://127.0.0.1${RUTA}'"

URL="http://web/_ver-menu.html?r=${RUTA}&w=${W}&h=${H}"
[ -n "$USUARIO" ] && URL="${URL}&u=${USUARIO}&p=${CLAVE}"

# La ventana va algo más ancha que el iframe para que no aparezca barra lateral
timeout 200 docker run --rm --network importtools_default \
  -v "$(pwd -W 2>/dev/null || pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome --headless=new --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars \
  --virtual-time-budget=22000 --window-size="$((W + 20)),$((H + 30))" \
  --screenshot="/out/$OUT" "$URL" 2>&1 | grep -E "bytes written" || echo "  la captura fallo"
