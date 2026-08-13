-- ===========================================================================
-- 27 — Los iconos que la tienda intentaba descargar de la LAN del autor del tema
-- Importtools S.A.S · prefijo psjy_ · 11/08/2026
-- ---------------------------------------------------------------------------
-- QUE ARREGLA
--   Con el modo de depuracion encendido, la portada devolvia HTTP 500 con:
--
--     Uncaught Exception: file_get_contents_curl failed to download
--     http://192.168.1.80/prestashop/custom/vt_autosoe/themes/vt_autosoe/
--     assets/img/modules/leoelements/images/phone.svg : (error code 28)
--     Connection timed out after 5002 milliseconds
--
--   `192.168.1.80` es la maquina de la RED LOCAL del autor de la plantilla.
--   Los contenidos de Leo Elements que venian con el tema guardaron ahi la
--   direccion de sus iconos SVG, y el modulo los pide por HTTP AL RENDERIZAR.
--   Desde el hosting esa IP no existe -> la peticion agota el tiempo de espera.
--
-- POR QUE SALTA "AL ACTIVAR EL MODO DE DEPURACION" Y NO ANTES
--   classes/Tools.php, en file_get_contents_curl():
--
--       if (false === $content && _PS_MODE_DEV_) {
--           throw new Exception($errorMessage);
--       }
--
--   Con el modo dev APAGADO el curl falla, devuelve false y nadie lanza nada:
--   la pagina se pinta (con el icono vacio) y el fallo queda invisible.
--   Con el modo dev ENCENDIDO lanza la excepcion, Hook.php:1251 la reenvia como
--   CoreException y no la recoge nadie -> 500.
--   O sea: el modo de depuracion no causo el fallo, lo DESTAPO.
--
--   El coste estaba ahi todo el tiempo: 3 s de fopen + 5 s de curl por icono,
--   4 iconos en la cabecera y 2 en el pie. Solo no se notaba porque el bloque
--   de la cabecera vive en la cache de Smarty y el hook casi nunca se ejecuta.
--   Cada vez que se vacia la cache, la primera visita lo paga entero.
--
-- QUE HACE EXACTAMENTE
--   En los 22 widgets `icon-box` afectados (x2 idiomas = 44 referencias):
--     a) vacia `library` ("svg" -> "")  → el modulo ya no descarga nada
--     b) cambia la URL de la LAN por la ruta local del tema hijo
--
--   Icons_Manager::render_icon() sale en la PRIMERA linea si `library` esta
--   vacio (`if (empty($icon['library'])) return false;`), asi que no llega a
--   tocar la red. Y `$has_icon` de icon-box.php NO depende de `library`, sino
--   de que `selected_icon.value` no este vacio — por eso se conserva el objeto
--   {url, id}: asi el `<div class="elementor-icon-box-icon">` se sigue pintando.
--
--   ⚠️ ASPECTO VISUAL: NO CAMBIA NADA. Esos iconos ya salian vacios hoy
--   (medido en la portada de produccion: 7 `.elementor-icon` sin nada dentro,
--   0 de los 5 SVG inlineados). Los que se ven los pinta nuestro custom.css:
--   `::before` sobre el texto en la barra de utilidades (§16.2) y los PNG del
--   cliente de fondo en los circulos rojos del pie (§16.3). Si en vez de esto
--   se "arreglara" la descarga, se inlinearian los SVG de la demo y saldrian
--   DOS iconos encimados — y uno de ellos, `garage-1.svg`, es un garaje en la
--   caja que hoy dice "Como llegar".
--
-- COMO SE USA
--   cPanel -> phpMyAdmin -> elige la base de la tienda -> pestana "SQL"
--   -> pega ESTE FICHERO ENTERO -> Continuar.
--
--   Es idempotente: se puede ejecutar dos veces sin romper nada.
--   Al terminar hay que VACIAR CACHES, o no se vera el efecto (ver el paso 5).
-- ===========================================================================

SET NAMES utf8mb4;
SET SQL_MODE = '';


-- ---------------------------------------------------------------------------
-- PASO 0 — Respaldo dentro de la propia base, antes de tocar nada.
--          Si la tabla ya existe de una ejecucion anterior, NO la pisa.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS psjy_leoelements_contents_lang_bk_20260811 AS
SELECT * FROM psjy_leoelements_contents_lang
 WHERE content LIKE '%192.168.1.80%';

SELECT '--- PASO 0 respaldo: deben salir 14 filas (7 contenidos x 2 idiomas) ---' AS ``;
SELECT id_leoelements_contents, id_lang, LENGTH(content) AS bytes
  FROM psjy_leoelements_contents_lang_bk_20260811
 ORDER BY id_leoelements_contents, id_lang;


-- ---------------------------------------------------------------------------
-- PASO 1 — Estado ANTES. Referencia para comparar con el paso 3.
--          Esperado: 14 filas, 44 URLs a la LAN, 44 iconos con library "svg".
-- ---------------------------------------------------------------------------
SELECT '--- PASO 1 antes ---' AS ``;
SELECT
  COUNT(*)                                                                  AS filas_afectadas,
  SUM((LENGTH(content) - LENGTH(REPLACE(content, '192.168.1.80', ''))) / 12) AS urls_a_la_lan,
  SUM((LENGTH(content) - LENGTH(REPLACE(content, '"library":"svg"', ''))) / 15) AS iconos_svg
FROM psjy_leoelements_contents_lang
WHERE content LIKE '%192.168.1.80%';


-- ---------------------------------------------------------------------------
-- PASO 2 — El arreglo.
--
--   Se reemplaza la cadena COMPLETA (url + id + library) de cada uno de los 5
--   ficheros, no trozos suel-tos. Comprobado contra la base: los 5 literales
--   cubren 44 de 44 apariciones, y NINGUNA otra fila de la tabla tiene
--   `"library":"svg"` — asi que no hay forma de tocar un icono que si funcione.
--
--   ⚠️ Los `\\/` NO son un error de escritura. El JSON guarda las barras
--   escapadas (`\/`), y en un literal de MySQL la barra invertida es a su vez
--   un caracter de escape: hay que escribir `\\/` para que llegue `\/`. Con una
--   sola barra, MySQL la descarta, el literal no casa con nada y el UPDATE
--   afecta a 0 filas SIN AVISAR. Por eso el paso 3 verifica de verdad.
-- ---------------------------------------------------------------------------
UPDATE psjy_leoelements_contents_lang
SET content =
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
    content,
    '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/phone.svg","id":0},"library":"svg"}',
    '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/phone.svg","id":0},"library":""}'),
    '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/clock.svg","id":0},"library":"svg"}',
    '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/clock.svg","id":0},"library":""}'),
    '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/message-chat-square.svg","id":0},"library":"svg"}',
    '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/message-chat-square.svg","id":0},"library":""}'),
    '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/garage-1.svg","id":0},"library":"svg"}',
    '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/garage-1.svg","id":0},"library":""}'),
    '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/mail-01.svg","id":0},"library":"svg"}',
    '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/mail-01.svg","id":0},"library":""}')
WHERE content LIKE '%192.168.1.80%';


-- ---------------------------------------------------------------------------
-- PASO 3 — VERIFICACION. Las cuatro columnas de la primera consulta deben dar
--          0. Si alguna no da 0, NO sigas: deshaz con el paso 6 y avisa.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 3 verificacion: las cuatro columnas deben ser 0 ---' AS ``;
SELECT
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%192.168.%')                       AS quedan_urls_a_la_lan,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%"library":"svg"%')                AS quedan_iconos_svg,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE JSON_VALID(content) = 0)                         AS json_roto,
  -- Cada icono corregido ahorra EXACTAMENTE 50 bytes: 47 del prefijo de la URL
  -- (75 del host de la LAN -> 28 de la ruta local) y 3 de "svg" -> "".
  -- Asi que los bytes que perdio cada fila tienen que ser 50 x sus iconos.
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang c
     JOIN psjy_leoelements_contents_lang_bk_20260811 b
       ON b.id_leoelements_contents = c.id_leoelements_contents
      AND b.id_lang = c.id_lang
    WHERE LENGTH(b.content) - LENGTH(c.content) <> 50 *
          ((LENGTH(b.content) - LENGTH(REPLACE(b.content, '192.168.1.80', ''))) / 12)
  )                                                         AS descuadre_de_bytes;

SELECT '--- PASO 3b las 44 referencias, ahora relativas al tema hijo (esperado: 44) ---' AS ``;
SELECT
  SUM((LENGTH(content) - LENGTH(REPLACE(content, '\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/', ''))) / 71) AS urls_locales
FROM psjy_leoelements_contents_lang;

-- Solo las 14 filas que tocamos (por eso el JOIN con el respaldo). Sin el JOIN
-- el recuento sale mucho mayor y confunde: `"library":""` ya existia en OTROS
-- contenidos (3, 7, 11, 15, 16) con 80 apariciones, porque es el valor NATIVO
-- del modulo para un icon-box sin icono. Eso es justo lo que confirma que este
-- arreglo no inventa un estado raro: usa el que el propio modulo ya usa.
SELECT '--- PASO 3c por contenido: esperado 4,2,4,2,4,2,4 por idioma (total 44) ---' AS ``;
SELECT c.id_leoelements_contents, c.id_lang,
       (LENGTH(c.content) - LENGTH(REPLACE(c.content, '"library":""', ''))) / 12 AS iconos
  FROM psjy_leoelements_contents_lang c
  JOIN psjy_leoelements_contents_lang_bk_20260811 b
    ON b.id_leoelements_contents = c.id_leoelements_contents
   AND b.id_lang = c.id_lang
 ORDER BY c.id_leoelements_contents, c.id_lang;


-- ---------------------------------------------------------------------------
-- PASO 4 — Invalidar el CSS que Elementor tiene generado en la base.
--          Vaciar var/cache/ NO invalida esto: el front seguiria sirviendo las
--          URLs viejas con la base ya corregida.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
SELECT '--- PASO 4 hecho: filas de CSS de Elementor que quedan (debe ser 0) ---' AS ``;
SELECT COUNT(*) AS css_en_base FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';


-- ---------------------------------------------------------------------------
-- PASO 5 — LO QUE FALTA, Y NO ES SQL. En este orden:
--
--   5.1  APAGAR EL MODO DE DEPURACION (es lo que convierte el fallo en un 500):
--        public_html/config/defines.inc.php   ->  define('_PS_MODE_DEV_', false);
--        Si existe public_html/config/defines_custom.inc.php, cambialo TAMBIEN
--        ahi: PrestaShop consulta ese fichero PRIMERO
--        (src/Adapter/Debug/DebugMode.php:41).
--
--   5.2  Borrar la carpeta public_html/var/cache/dev  completa.
--        Ademas de forzar el modo produccion, libera inodos: el plan H2 trae
--        ~200.000 y la cache `dev` crea miles de ficheros.
--
--   5.3  Vaciar la cache normal: back office -> Parametros avanzados ->
--        Rendimiento -> "Vaciar la cache".  (O borrar var/cache/prod/*.)
--        Sin esto la cabecera se sigue sirviendo de la cache de Smarty y no se
--        nota ningun cambio — ni bueno ni malo.
--
--   5.4  Comprobar: pedir la portada y que devuelva 200. La PRIMERA visita
--        despues de vaciar cache es la que antes pagaba los tiempos de espera;
--        si ahora responde en ~1-2 s en vez de ~30 s, esta arreglado.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- PASO 6 — MARCHA ATRAS (no ejecutar salvo que el paso 3 falle).
--          Devuelve las 14 filas exactamente como estaban.
--
--   UPDATE psjy_leoelements_contents_lang c
--     JOIN psjy_leoelements_contents_lang_bk_20260811 b
--       ON b.id_leoelements_contents = c.id_leoelements_contents
--      AND b.id_lang = c.id_lang
--      SET c.content = b.content;
--   DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
--
--   Y despues vaciar cachés (paso 5.3).
-- ---------------------------------------------------------------------------
