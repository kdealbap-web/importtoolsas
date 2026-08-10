#!/usr/bin/env bash
# Empuja el tema hijo y los modulos propios del repo al espejo, y vacia la cache.
#   ./local-dev/publicar-tema.sh
# La cache se borra COMO www-data: hacerlo como root deja var/cache/prod sin
# permiso de escritura y el front devuelve 500 con
# «SmartyException: unable to create directory var/cache/...».
set -euo pipefail
cd "$(dirname "$0")/.."
export MSYS_NO_PATHCONV=1

CHILD=/var/www/html/themes/vt_autosoe_child

# El tema hijo tiene UNA sola fuente en el repo: `theme-autosoe/vt_autosoe_child/`.
# Es la misma carpeta de la que `empaquetar.py` construye el zip de despliegue, asi
# que lo que se publica en el espejo y lo que sube al servidor son, por definicion,
# el mismo arbol.
#
# ⚠️ Historia, para que no se repita (10/08/2026): antes habia TRES sitios con
# ficheros del tema —`theme-autosoe/custom.css`, `theme-autosoe/templates/` y el
# propio `vt_autosoe_child/`—, con copias identicas que habia que mantener a mano.
# Este script publicaba solo los dos primeros, asi que las plantillas del hijo se
# editaban, se ejecutaba esto, y el espejo seguia sirviendo la version vieja. Los
# duplicados se eliminaron; no volver a crearlos.
# De una vez todo el arbol: `docker cp <dir>/.` copia el CONTENIDO dentro del
# destino, sobrescribiendo lo que coincida y dejando intacto lo que no venga en el
# origen. Fichero a fichero eran 472 invocaciones de docker.
docker cp theme-autosoe/vt_autosoe_child/. "it_web:$CHILD/" >/dev/null
docker exec it_web sh -c "chown -R www-data:www-data '$CHILD'"
echo "  -> $CHILD  ($(find theme-autosoe/vt_autosoe_child -type f | wc -l) ficheros)"

# Modulos propios
for m in modules-custom/*/; do
  [ -d "$m" ] || continue
  nombre=$(basename "$m")
  docker cp "$m." "it_web:/var/www/html/modules/$nombre/" >/dev/null
  docker exec it_web sh -c "chown -R www-data:www-data /var/www/html/modules/$nombre"
  echo "  -> modules/$nombre"
done

echo "Vaciando caches (como www-data)"
docker exec -u www-data it_web sh -c '
  rm -rf /var/www/html/var/cache/* 2>/dev/null
  rm -f  /var/www/html/themes/vt_autosoe_child/assets/cache/* 2>/dev/null
  rm -f  /var/www/html/modules/leoelements/gencode/* 2>/dev/null
  true'
echo "LISTO"
