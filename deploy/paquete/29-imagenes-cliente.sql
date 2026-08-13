-- ===========================================================================
-- 29 — Las fotos del cliente en el home y en las bandas de categoria
-- Importtools S.A.S · prefijo psjy_ · 12/08/2026
-- ---------------------------------------------------------------------------
-- QUE HACE
--   Repunta SEIS huecos de Leo Elements a ficheros nuevos. Los otros diez de las
--   16 fotos que entrego el cliente NO necesitan SQL: se sobrescribe el fichero
--   con el mismo nombre y ya, porque cada uno lo usa un solo bloque.
--
-- POR QUE ESTOS SEIS SI
--   `banner-med-a.jpg` y `banner-med-b.jpg` los comparten TRES bloques cada uno,
--   y cada bloque necesita una foto distinta. Contado sobre el JSON, no a ojo:
--
--     banner-med-a.jpg  11 usos = 5 contenidos x (banda b9df906 + tarjeta del
--                                 carrusel 5bcf0be)  +  1 en el contenido 17
--     banner-med-b.jpg  11 usos = igual, con la banda 0712bb7
--
--   Un `REPLACE` a secas sobre el nombre del fichero cambiaria los tres a la vez
--   y pondria, por ejemplo, la foto de «Compra por bulto» dentro de la tarjeta de
--   «Herramientas de Medicion». Es la misma trampa del 03/08 con
--   `banner-med-a.jpg` en el pie (40 coincidencias en 18 filas).
--
--   La salida es que en el JSON el hueco se distingue por su CLAVE:
--     · banda de seccion  ->  "background_overlay_image":{"url":"…"}
--     · tarjeta del carrusel -> "item_image":{"url":"…"}
--   Comprobado imprimiendo el contexto crudo de las cuatro apariciones.
--
-- EL EMPAREJAMIENTO, y como se determino
--   Para cada hueco se cruzaron tres cosas independientes: el TEXTO que el bloque
--   muestra en el HTML de produccion, la DIMENSION del fichero que hay hoy, y el
--   NOMBRE que el cliente le puso a su foto. Coinciden en los seis:
--
--   | hueco (contenido:elemento)     | texto que muestra                        | fichero nuevo        |
--   |--------------------------------|------------------------------------------|----------------------|
--   | 3,7,11,15,16 : b9df906         | Mayoristas / Compra por bulto            | bulto.jpg            |
--   | 3,7,11,15,16 : 0712bb7         | Marca propia / Marca Nikato              | nikatto.jpg          |
--   | 3,7,11,15,16 : 5bcf0be item 7  | Herramientas de Medicion                 | medicion.jpg         |
--   | 3,7,11,15,16 : 5bcf0be item 8  | Herramientas de Corte                    | corte.jpg            |
--   | 17 : dff2c7b                   | Nuestro catalogo / mas de 3.000 refer.   | cat-referencias.jpg  |
--   | 17 : ccce7a0                   | Atencion mayorista / precios por volumen | cat-volumen.jpg      |
--
--   El par (imagen, titulo) de las dos tarjetas se leyo del DOM servido por
--   produccion, no del orden del JSON:
--     …/img/it/banner-med-a.jpg" alt=""/> Herramientas de Medicion
--     …/img/it/banner-med-b.jpg" alt=""/> Herramientas de Corte
--
-- ANTES DE EJECUTAR: hay que haber subido a  <docroot>/img/it/  los 13 ficheros
--   nuevos o cambiados. Si se ejecuta el SQL sin las imagenes, las bandas quedan
--   con el color de respaldo hasta que se suban. No se rompe nada.
--
-- COMO SE USA
--   cPanel -> phpMyAdmin -> base de la tienda -> pestaña «SQL» -> pegar entero.
--   Es idempotente: a la segunda pasada afecta a 0 filas.
--   Al terminar, VACIAR CACHES (paso 4) o no se nota nada.
-- ===========================================================================

SET NAMES utf8mb4;
SET SQL_MODE = '';


-- ---------------------------------------------------------------------------
-- PASO 0 — Respaldo. Solo las filas que se van a tocar. Si ya existe, no la pisa.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS psjy_leoelements_contents_lang_bk_20260812 AS
SELECT * FROM psjy_leoelements_contents_lang
 WHERE content LIKE '%banner-med-a.jpg%' OR content LIKE '%banner-med-b.jpg%';

SELECT '--- PASO 0 respaldo ---' AS ``;
SELECT COUNT(*) AS filas_respaldadas FROM psjy_leoelements_contents_lang_bk_20260812;
-- Esperado: 12 (6 contenidos x 2 idiomas). Si sale 0 es que ya se aplico antes.


-- ---------------------------------------------------------------------------
-- PASO 1 — Que hay ANTES, hueco por hueco.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 1 antes ---' AS ``;
SELECT id_leoelements_contents AS contenido, id_lang AS lang,
       (LENGTH(content) - LENGTH(REPLACE(content,
          '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"', '')))
          DIV LENGTH('"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"') AS banda_a,
       (LENGTH(content) - LENGTH(REPLACE(content,
          '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"', '')))
          DIV LENGTH('"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"') AS banda_b,
       (LENGTH(content) - LENGTH(REPLACE(content,
          '"item_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"', '')))
          DIV LENGTH('"item_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"') AS tarjeta_a,
       (LENGTH(content) - LENGTH(REPLACE(content,
          '"item_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"', '')))
          DIV LENGTH('"item_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"') AS tarjeta_b
  FROM psjy_leoelements_contents_lang
 WHERE content LIKE '%banner-med-%'
 ORDER BY id_leoelements_contents, id_lang;


-- ---------------------------------------------------------------------------
-- PASO 2 — Las dos TARJETAS del carrusel de categorias.
--          Se acota por la clave `item_image`, asi no toca las bandas.
--          Va primero a proposito: si se hicieran antes las bandas, el nombre
--          `banner-med-a.jpg` ya no estaria en ellas y da igual, pero al reves
--          tambien funciona. El orden no importa porque las claves son distintas.
-- ---------------------------------------------------------------------------
-- ⚠️ El guardian del WHERE va SIN barras invertidas a proposito. En un patron
--    LIKE el `\` es a su vez caracter de escape, asi que para buscar el `\/` del
--    JSON haria falta escribir `\\\\/` y es facil equivocarse: con `\\/` el LIKE
--    entiende «barra normal» y no casa con nada, el UPDATE afecta a 0 filas y
--    parece que el script no hizo nada. Basta con el nombre del fichero, que ya
--    es unico. El acotado fino lo hace el REPLACE, que no interpreta patrones.
UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"item_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"',
         '"item_image":{"url":"\\/img\\/it\\/medicion.jpg"')
 WHERE content LIKE '%banner-med-a.jpg%';

UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"item_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"',
         '"item_image":{"url":"\\/img\\/it\\/corte.jpg"')
 WHERE content LIKE '%banner-med-b.jpg%';


-- ---------------------------------------------------------------------------
-- PASO 3 — Las dos BANDAS del home (b9df906 y 0712bb7).
--          Se acota por la clave `background_overlay_image` Y por el contenido:
--          el 17 tiene la misma clave con el mismo fichero y necesita otra foto.
-- ---------------------------------------------------------------------------
UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"',
         '"background_overlay_image":{"url":"\\/img\\/it\\/bulto.jpg"')
 WHERE id_leoelements_contents <> 17 AND content LIKE '%banner-med-a.jpg%';

UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"',
         '"background_overlay_image":{"url":"\\/img\\/it\\/nikatto.jpg"')
 WHERE id_leoelements_contents <> 17 AND content LIKE '%banner-med-b.jpg%';


-- ---------------------------------------------------------------------------
-- PASO 4 — Las dos BANDAS de las paginas de categoria (contenido 17).
-- ---------------------------------------------------------------------------
UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-a.jpg"',
         '"background_overlay_image":{"url":"\\/img\\/it\\/cat-referencias.jpg"')
 WHERE id_leoelements_contents = 17 AND content LIKE '%banner-med-a.jpg%';

UPDATE psjy_leoelements_contents_lang
   SET content = REPLACE(content,
         '"background_overlay_image":{"url":"\\/img\\/it\\/banner-med-b.jpg"',
         '"background_overlay_image":{"url":"\\/img\\/it\\/cat-volumen.jpg"')
 WHERE id_leoelements_contents = 17 AND content LIKE '%banner-med-b.jpg%';


-- ---------------------------------------------------------------------------
-- PASO 5 — VERIFICACION. Las dos primeras columnas tienen que dar 0.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 5 verificacion ---' AS ``;
SELECT
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%banner-med-a.jpg%')                        AS quedan_med_a,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%banner-med-b.jpg%')                        AS quedan_med_b,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%bulto.jpg%')                               AS con_bulto,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%nikatto.jpg%')                             AS con_nikatto,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%medicion.jpg%')                            AS con_medicion,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%corte.jpg%')                               AS con_corte,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%cat-referencias.jpg%')                     AS con_referencias,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE content LIKE '%cat-volumen.jpg%')                         AS con_volumen,
  (SELECT COUNT(*) FROM psjy_leoelements_contents_lang
     WHERE JSON_VALID(content) = 0)                                  AS json_roto;

-- Esperado con 5 contenidos del home (3,7,11,15,16) y el 17, en 2 idiomas:
--   quedan_med_a 0 · quedan_med_b 0 · json_roto 0
--   con_bulto 10 · con_nikatto 10 · con_medicion 10 · con_corte 10
--   con_referencias 2 · con_volumen 2


-- ---------------------------------------------------------------------------
-- PASO 6 — Invalidar el CSS que Elementor guarda EN LA BASE.
--   Vaciar var/cache/ NO basta: `psjy_leoelements_meta` guarda el CSS generado y
--   el front seguiria sirviendo las URLs viejas con la base ya cambiada. Pasa
--   siempre que se toca contenido de Leo Elements.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
SELECT '--- PASO 6 ---' AS ``;
SELECT COUNT(*) AS css_de_elementor_en_base FROM psjy_leoelements_meta
 WHERE name LIKE '%elementor_css%';       -- tiene que dar 0


-- ---------------------------------------------------------------------------
-- PASO 7 — LO QUE FALTA Y NO ES SQL
--   7.1  Subir a <docroot>/img/it/ los 13 ficheros (7 sobrescritos + 6 nuevos).
--   7.2  Subir el tema hijo (custom.css y custom.js cambian en esta ronda).
--   7.3  Back office -> Parametros avanzados -> Rendimiento -> Vaciar la cache.
--   7.4  Recargar la portada con Ctrl+F5. Los 7 ficheros sobrescritos conservan
--        el nombre, asi que el navegador puede seguir sirviendo el viejo de su
--        cache; en el servidor, purgar LSCache desde cPanel.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- PASO 8 — MARCHA ATRAS
--
--   UPDATE psjy_leoelements_contents_lang c
--     JOIN psjy_leoelements_contents_lang_bk_20260812 b
--       ON b.id_leoelements_contents = c.id_leoelements_contents
--      AND b.id_lang = c.id_lang
--      SET c.content = b.content;
--   DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
--
--   Y volver a poner los 7 ficheros sobrescritos desde
--   deploy/img/it/_respaldo-20260812/.
-- ---------------------------------------------------------------------------
