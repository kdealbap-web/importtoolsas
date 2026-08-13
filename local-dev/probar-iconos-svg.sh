#!/bin/bash
# ---------------------------------------------------------------------------
# probar-iconos-svg.sh — mide lo que cuesta un icono SVG remoto en los
# contenidos de Leo Elements, y verifica el arreglo 27.
#
# Contexto: los contenidos que venian con la plantilla guardaban sus iconos
# como URL a `192.168.1.80`, la LAN del autor del tema. El modulo los pide por
# HTTP EN CADA RENDER (modules/leoelements/core/files/assets/svg/svg-handler.php
# :166). Desde el hosting esa IP no existe: 3 s de fopen + 5 s de curl por
# icono. Con `_PS_MODE_DEV_` apagado el fallo es MUDO (Tools.php solo lanza la
# excepcion `if (false === $content && _PS_MODE_DEV_)`); con el encendido, 500.
#
# Uso:  bash local-dev/probar-iconos-svg.sh            # solo mide
#       bash local-dev/probar-iconos-svg.sh --con-dev  # mide tambien con dev=on
#
# ⚠️ OPcache: tras cambiar defines.inc.php hay que esperar
#    `opcache.revalidate_freq` (2 s aqui) o reiniciar el contenedor, o el
#    servidor sigue viendo el valor viejo y parece que el cambio no hace nada.
# ---------------------------------------------------------------------------
set -u
P=~/importtools/prestashop
D="$P/config/defines.inc.php"
OUT=$(mktemp -d)

vaciar() { docker exec -u www-data it_web bash -c \
  'rm -rf /var/www/html/var/cache/prod/* /var/www/html/var/cache/dev' 2>/dev/null; }
dev() { sed -i "s/define('_PS_MODE_DEV_', [^)]*)/define('_PS_MODE_DEV_', $1)/" "$D"
        docker restart it_web >/dev/null; sleep 6; }

echo "=== 1) Iconos SVG remotos que quedan en la base ==="
docker exec -i it_db mariadb -uroot -proot importtools -N -B -e "
SELECT CONCAT('  filas con URL a la LAN : ', COUNT(*)),
       CONCAT('  referencias            : ',
              IFNULL(SUM((LENGTH(content)-LENGTH(REPLACE(content,'192.168.1.80','')))/12),0))
  FROM psjy_leoelements_contents_lang WHERE content LIKE '%192.168.1.80%';" | tr '\t' '\n'

echo
echo "=== 2) La IP, desde el contenedor (asi la ve el servidor) ==="
docker exec it_web bash -c 'curl -s -o /dev/null -m 6 \
  -w "  192.168.1.80 -> codigo=%{http_code} tiempo=%{time_total}s\n" http://192.168.1.80/ || true'

echo
echo "=== 3) Coste de la PRIMERA visita con la cache vacia ==="
echo "    (es lo que paga el primer visitante cada vez que se vacia la cache)"
vaciar
curl -s -o "$OUT/1.html" -w "  1a visita: HTTP %{http_code}  %{time_total}s  size=%{size_download}\n" http://localhost:8080/
curl -s -o "$OUT/2.html" -w "  2a visita: HTTP %{http_code}  %{time_total}s  size=%{size_download}\n" http://localhost:8080/
echo "  Referencia: con los iconos arreglados son ~2 s. Sin arreglar, ~50 s."

echo
echo "=== 4) Los iconos en el HTML servido (deben salir vacios: los pinta el CSS) ==="
for m in "elementor-icon-box-icon" "elementor-icon elementor-animation-" "<svg" "192.168"; do
  printf "  %-38s %s\n" "$m" "$(grep -o "$m" "$OUT/2.html" | wc -l)"
done

if [ "${1:-}" = "--con-dev" ]; then
  echo
  echo "=== 5) Con _PS_MODE_DEV_ encendido (reproduce el 500 si NO esta arreglado) ==="
  dev true
  vaciar
  curl -s -o "$OUT/dev.html" -w "  HTTP %{http_code}  %{time_total}s  size=%{size_download}\n" http://localhost:8080/
  grep -oE "(file_get_contents_curl failed to download [^ <]*|Uncaught Exception|error code 28)" \
    "$OUT/dev.html" | sort -u | sed 's/^/    /'
  dev false
  vaciar
  echo "  (modo dev devuelto a false)"
fi
rm -rf "$OUT"
