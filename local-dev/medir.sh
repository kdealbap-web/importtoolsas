#!/usr/bin/env bash
# Mide cajas y estilos calculados y devuelve TEXTO por stdout, no un PNG.
#
#   ./local-dev/medir.sh <ruta> <ancho> [selectores separados por |] [props] [clic]
#   ./local-dev/medir.sh / 390 '.navbar-toggler|.box__truck .slick-slide' 'background-color'
#
# Es el mismo `_inspeccionar.html` que usa `inspeccionar.sh`, pero en lugar de
# fotografiar la pagina de resultados se usa `--dump-dom` y se extrae el <div
# id="res">. Motivo: leer una captura para enterarse de un `w=0` es caro y se
# presta a interpretar mal; el texto se lee tal cual.
#
# ⚠️ Mantiene las dos precauciones de `inspeccionar.sh`, que no son opcionales:
#   · el dominio se cambia a `web` mientras dura la medida (el espejo redirige al
#     canonico y dentro de la red de Docker el host es `web`), y se restaura al
#     salir incluso si algo falla;
#   · por debajo de 520 px se manda user-agent de iPhone, porque hay modulos
#     —LeoSlideshow el primero— que eligen QUE SERVIR en el servidor mirando el
#     user-agent. Sin esto se mide el componente de escritorio encogido.
set -euo pipefail
cd "$(dirname "$0")/.."

RUTA="${1:-/}"
W="${2:-390}"
SELS="${3:-}"
PROPS="${4:-}"
CLIC="${5:-}"

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

# calentar la ruta: la primera peticion tras vaciar cache tarda ~50 s y se mediria
# una pagina a medio construir
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 'http://127.0.0.1${RUTA}'"

URL="http://web/_inspeccionar.html?r=${RUTA}&w=${W}"
[ -n "$SELS" ]  && URL="${URL}&s=${SELS}"
[ -n "$PROPS" ] && URL="${URL}&p=${PROPS}"
[ -n "$CLIC" ]  && URL="${URL}&c=${CLIC}"

UA=""
if [ "$W" -lt 520 ]; then
  UA="--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
fi

DOM="$(mktemp)"
timeout 200 docker run --rm --network importtools_default \
  --entrypoint chromium-browser zenika/alpine-chrome \
  --headless=old --no-sandbox --disable-gpu --disable-dev-shm-usage \
  ${UA:+"$UA"} --virtual-time-budget=25000 --window-size=1200,2400 \
  --dump-dom "$URL" >"$DOM" 2>/dev/null || true

# El textContent del informe lleva saltos de linea, asi que el bloque abarca
# varias lineas del volcado: hay que extraerlo por rango, no con un sed de una
# linea (eso devolvia vacio y parecia que la medicion habia fallado).
sed -n '/<div id="res">/,/<\/div>/p' "$DOM" \
  | sed -e 's/<div id="res">//' -e 's/<\/div>//' \
        -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&amp;/\&/g'
rm -f "$DOM"
