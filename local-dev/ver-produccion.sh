#!/usr/bin/env bash
# Captura PRODUCCION con Chromium headless.  Uso:
#   ./local-dev/ver-produccion.sh <salida.png> [ruta] [ancho] [alto]
#
# Es el hermano de `captura.sh`, que solo sabe mirar el espejo. Dos diferencias:
#
#  · La pagina se carga dentro de un iframe del ancho pedido, servido por
#    `file://`. Chromium no baja de ~500 px de VENTANA, pero un iframe si acepta
#    el ancho real. Aqui el iframe apunta a otro origen, lo cual impide LEER su
#    DOM —y por eso esto solo hace capturas, no mediciones—, pero para pintar y
#    fotografiar da igual: se renderiza igual que en un telefono.
#
#  · Por debajo de 520 px se manda user-agent de iPhone, y no es un detalle
#    cosmetico: LeoSlideshow elige EN EL SERVIDOR, mirando el user-agent, si
#    sirve el grupo de escritorio o el de movil. Sin esto se fotografia el
#    componente de escritorio encogido y se concluye cualquier cosa.
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:?falta el nombre de salida}"
RUTA="${2:-/}"
W="${3:-1440}"
H="${4:-2200}"
DIR="tmp-shots"
URL_BASE="${SITE_URL:-https://www.importtoolsas.com}"
mkdir -p "$DIR"

# El `?v=` evita que responda una copia cacheada por LSCache.
DESTINO="${URL_BASE}${RUTA}"
case "$DESTINO" in *\?*) DESTINO="${DESTINO}&v=$$" ;; *) DESTINO="${DESTINO}?v=$$" ;; esac

cat > "$DIR/_prod.html" <<HTML
<!doctype html><meta charset="utf-8">
<style>html,body{margin:0;padding:0;background:#fff}iframe{border:0;display:block}</style>
<iframe src="${DESTINO}" width="${W}" height="${H}"></iframe>
HTML

UA=""
MODO="--headless=old"
if [ "$W" -lt 520 ]; then
  MODO="--headless=new"
  UA="--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
fi

timeout 240 docker run --rm \
  -v "$(pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome $MODO --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars ${UA:+"$UA"} \
  --virtual-time-budget=30000 --window-size="$((W + 20)),$((H + 20))" \
  --screenshot="/out/$OUT" "file:///out/_prod.html" 2>&1 \
  | grep -E "bytes written" || echo "  la captura fallo"

rm -f "$DIR/_prod.html"
