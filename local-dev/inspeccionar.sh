#!/usr/bin/env bash
# Mide cajas y estilos calculados de la tienda dentro de un iframe del ancho real.
#   ./local-dev/inspeccionar.sh <salida.png> <ruta> <ancho> [selectores separados por |] [props]
# Ej: ./local-dev/inspeccionar.sh insp-movil.png / 390
#     ./local-dev/inspeccionar.sh insp.png / 1440 '.header__search|.navbar-toggler' 'display,color'
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:?falta el nombre de salida}"
RUTA="${2:-/}"
W="${3:-390}"
SELS="${4:-}"
PROPS="${5:-}"
DIR="tmp-shots"
mkdir -p "$DIR"

docker exec it_db mysql -uroot -proot importtools -e "
  UPDATE psjy_shop_url SET domain='web', domain_ssl='web' WHERE id_shop=1;
  UPDATE psjy_configuration SET value='web' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null

restaurar() {
  docker exec it_db mysql -uroot -proot importtools -e "
    UPDATE psjy_shop_url SET domain='localhost:8080', domain_ssl='localhost:8080' WHERE id_shop=1;
    UPDATE psjy_configuration SET value='localhost:8080' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" 2>/dev/null
}
trap restaurar EXIT

docker cp local-dev/_inspeccionar.html it_web:/var/www/html/_inspeccionar.html >/dev/null
docker exec it_web sh -c 'chown www-data:www-data /var/www/html/_inspeccionar.html'

# calentar la ruta medida: la primera peticion tras vaciar cache tarda ~50 s
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 'http://127.0.0.1${RUTA}'"

URL="http://web/_inspeccionar.html?r=${RUTA}&w=${W}"
[ -n "${6:-}" ] && URL="${URL}&c=${6}"
[ -n "$SELS" ]  && URL="${URL}&s=${SELS}"
[ -n "$PROPS" ] && URL="${URL}&p=${PROPS}"

# ⚠️ Mismo motivo que en `captura.sh`: hay modulos que deciden QUE SERVIR en el
# servidor mirando el user-agent, no con CSS. LeoSlideshow monta el grupo de
# escritorio o el de movil segun el dispositivo y solo renderiza UNO. Sin esto,
# medir «en movil» devolvia medidas del componente de ESCRITORIO encogido.
UA=""
if [ "$W" -lt 520 ]; then
  UA="--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
fi

MSYS_NO_PATHCONV=1 timeout 200 docker run --rm --network importtools_default \
  -v "$(pwd -W 2>/dev/null || pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome --headless=old --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars ${UA:+"$UA"} \
  --virtual-time-budget=20000 --window-size=1200,2400 \
  --screenshot="/out/$OUT" "$URL" 2>&1 | grep -E "bytes written" || echo "  la captura fallo"
