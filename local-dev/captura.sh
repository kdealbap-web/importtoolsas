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

# --- ANCHO MINIMO DE VENTANA -------------------------------------------------
# Chromium NO baja de ~500 px de ventana. Con --window-size=390 maqueta a 500 y
# recorta el PNG a 390: se ve texto y tarjetas cortadas a la derecha y parece un
# desbordamiento que no existe. Comprobado midiendo dentro de la pagina:
# con --window-size=390, window.innerWidth devolvia 500.
# Un IFRAME si acepta anchos pequenos de verdad, asi que por debajo de 520 px se
# carga la ruta dentro de /_movil.html, que es un iframe del ancho pedido.
URL_PATH="$RUTA"
VENTANA_W="$W"
UA=""
if [ "$W" -lt 520 ]; then
  docker cp local-dev/_movil.html it_web:/var/www/html/_movil.html >/dev/null
  docker exec it_web sh -c 'chown www-data:www-data /var/www/html/_movil.html'
  URL_PATH="/_movil.html?r=${RUTA}&w=${W}&h=${H}"
  VENTANA_W=$(( W + 10 ))
  MODO="--headless=new"          # el viejo pinta gris por debajo de ~768

  # --- USER-AGENT DE MOVIL -------------------------------------------------
  # ⚠️ No basta con estrechar la ventana. Hay modulos que eligen QUE SERVIR en
  # el SERVIDOR, mirando el user-agent, no con CSS. El caso claro es
  # LeoSlideshow: el home monta el grupo 3 (1920x700, escritorio) o el grupo 5
  # (460x460, movil) segun el dispositivo, y solo renderiza UNO.
  #
  # Sin esta linea, el iframe pedia la pagina con el user-agent de Chromium de
  # escritorio: el servidor devolvia el slideshow de 1920x700 y el iframe lo
  # encogia a 390 px -> 142 px de alto con el texto al 20 %. Parecia que el hero
  # movil estaba roto e ilegible, y NO lo estaba: en un telefono de verdad se
  # sirve el grupo movil. Comprobado pidiendo la misma URL con los dos
  # user-agent: `iview-group-...-3` frente a `iview-group-...-5`.
  #
  # Misma clase de error que el 404 de las fotos: la herramienta mintiendo, no
  # la tienda. Por eso va aqui dentro y no en cada llamada.
  UA="--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
else
  MODO="--headless=old"          # el nuevo se cuelga a veces sin escribir el fichero
fi

# calentar: la primera peticion tras vaciar cache tarda ~50 s y la captura sale en blanco
docker exec it_web sh -c "curl -s -o /dev/null -H 'Host: web' --max-time 250 http://127.0.0.1${RUTA}"

# MSYS_NO_PATHCONV=1 evita que Git Bash convierta /out en C:/Program Files/Git/out
MSYS_NO_PATHCONV=1 timeout 200 docker run --rm --network importtools_default \
  -v "$(pwd -W 2>/dev/null || pwd)/$DIR:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome $MODO --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars ${UA:+"$UA"} \
  --virtual-time-budget=16000 --window-size="$VENTANA_W,$H" \
  --screenshot="/out/$OUT" "http://web${URL_PATH}" 2>&1 | grep -E "bytes written" || echo "  la captura fallo"
