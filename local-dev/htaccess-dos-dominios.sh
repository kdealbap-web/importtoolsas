#!/usr/bin/env bash
# Deja el .htaccess del ESPEJO aceptando los dos nombres con los que se le llama.
#
# ⚠️ POR QUE HACE FALTA, y por que importa tambien en produccion:
#
# `Tools::generateHtaccess()` escribe las reglas de imagen de producto guardadas
# por el dominio de la tienda:
#
#     RewriteCond %{HTTP_HOST} ^localhost:8080$
#     RewriteRule ^(([\d])([\d])(?:\-[\w-]*)?)/.+(\.(?:jpe?g|...))$  img/p/$2/$3/$1$4 [L]
#
# Es decir: **el dominio queda escrito dentro del .htaccess**. Si la peticion
# llega con otro nombre de host, la condicion no casa, la reescritura no ocurre y
# la imagen devuelve 404 — aunque el fichero este perfectamente en disco.
#
# En el espejo lo notamos porque `captura.sh` cambia el dominio a `web` para
# saltarse la redireccion canonica: las fotos de producto salian rotas.
#
# En PRODUCCION la consecuencia es la misma y mas seria: con el .htaccess
# generado para `www.importtoolsas.com`, **quien entre por `importtoolsas.com`
# (sin www) vera todas las fotos de producto rotas**. Es un motivo mas para
# cerrar el 301 a un solo dominio (ver 19-PLAN §1).
#
# Uso:  ./local-dev/htaccess-dos-dominios.sh
set -euo pipefail

echo "=== antes ==="
docker exec it_web sh -c "grep -c 'RewriteCond %{HTTP_HOST}' /var/www/html/.htaccess || true"

# Se sustituye la condicion de host por una que acepte los dos nombres del espejo.
docker exec it_web sh -c '
  sed -i -E "s|^RewriteCond %\{HTTP_HOST\} \^(localhost:8080\|web)\\\$$|RewriteCond %{HTTP_HOST} ^(localhost:8080\|web)$|" /var/www/html/.htaccess
'

echo "=== despues ==="
docker exec it_web sh -c "grep -m3 'RewriteCond %{HTTP_HOST}' /var/www/html/.htaccess"

echo
echo "=== comprobacion: la misma imagen por los dos nombres ==="
for h in "localhost:8080" "web"; do
  printf "  Host %-16s -> " "$h"
  docker exec it_web sh -c "curl -s -o /dev/null -w '%{http_code} %{size_download}b\n' -H 'Host: $h' 'http://127.0.0.1/28-home_default/x.jpg'"
done
