-- ===========================================================================
-- 28 — Quitar TODAS las capas de las diapositivas del hero
-- Importtools S.A.S · prefijo psjy_ · 11/08/2026
-- ---------------------------------------------------------------------------
-- QUE ARREGLA
--   El diseñador sube su imagen al slide y encima le siguen saliendo textos
--   genericos que no puso el:
--
--       TORNILLERIA Y <br> HERRAMIENTA MANUAL
--       Mas de 3.000 referencias disponibles. <br> Consulta precios por volumen.
--       Ver catalogo                                   (boton)
--       + 2 capas de IMAGEN de relleno de la demo ("Your Image Here 1" y "3"),
--         que son un GIF transparente y salen como <img> rotas en el HTML.
--
--   NO estaba quemado en el codigo. Comprobado: 0 reglas `content:` con ese
--   texto en custom.css, custom.js no toca el slideshow, y el tema hijo no
--   tiene ninguna plantilla de leoslideshow. Es DATO.
--
-- DONDE VIVE
--   psjy_leoslideshow_slides_lang.layersparams  = base64 de un JSON con la
--   lista de capas. Cada capa lleva `layer_type` (text|image), `layer_caption`
--   (el texto que se ve) y `layer_content` (la imagen).
--   La imagen DE FONDO de la diapositiva NO esta ahi: esta en la columna
--   `image` de esa misma tabla. Por eso vaciar `layersparams` quita los textos
--   y NO toca la foto que sube el diseñador.
--
-- QUE HACE
--   Deja `layersparams` vacio en TODAS las diapositivas y TODOS los idiomas.
--   A partir de aqui, un slide = la imagen que suba el diseñador, y punto.
--   Si algun dia quiere volver a poner un titular, lo añade el mismo desde
--   Diseño -> Leo Slideshow -> editar la diapositiva -> capas.
--
--   ⚠️ CONSECUENCIA QUE HAY QUE SABER: el hero se queda SIN titular y SIN
--   boton. Es exactamente lo pedido, pero conviene decirselo al cliente.
--
-- PROBADO EN EL ESPEJO
--   antes: 5 `tp-caption` en escritorio y 6 en movil, con el texto generico.
--   despues: 0 capas, la imagen del slide intacta (`data-leo_image` sigue),
--   0 <img> rotas, HTTP 200 y 0 errores de PHP.
--
-- COMO SE USA
--   cPanel -> phpMyAdmin -> base de la tienda -> pestaña "SQL" -> pegar entero.
--   Es idempotente. Al terminar hay que VACIAR CACHES o no se nota nada.
-- ===========================================================================

SET NAMES utf8mb4;
SET SQL_MODE = '';


-- ---------------------------------------------------------------------------
-- PASO 0 — Respaldo completo de la tabla. Si ya existe, no la pisa.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS psjy_leoslideshow_slides_lang_bk_20260811 AS
SELECT * FROM psjy_leoslideshow_slides_lang;

SELECT '--- PASO 0 respaldo ---' AS ``;
SELECT COUNT(*) AS filas_respaldadas,
       SUM(layersparams <> '') AS filas_con_capas
  FROM psjy_leoslideshow_slides_lang_bk_20260811;


-- ---------------------------------------------------------------------------
-- PASO 1 — Que hay ANTES, diapositiva por diapositiva.
--          `capas` cuenta las apariciones de "layer_type" en el JSON decodificado.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 1 antes: capas por diapositiva ---' AS ``;
SELECT s.id_group                        AS grupo,
       s.id_leoslideshow_slides          AS slide,
       s.active                          AS activa,
       sl.id_lang                        AS idioma,
       sl.image                          AS imagen_de_fondo,
       CASE WHEN sl.layersparams = '' THEN 0 ELSE
         (LENGTH(CONVERT(FROM_BASE64(sl.layersparams) USING utf8mb4))
          - LENGTH(REPLACE(CONVERT(FROM_BASE64(sl.layersparams) USING utf8mb4),
                           'layer_type', ''))) / 10
       END                               AS capas
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang sl
    ON sl.id_leoslideshow_slides = s.id_leoslideshow_slides
 ORDER BY s.id_group, s.position, sl.id_lang;


-- ---------------------------------------------------------------------------
-- PASO 2 — El borrado.
--          Solo toca `layersparams`. NO toca `image`, ni `link`, ni `title`,
--          ni la tabla de diapositivas: la foto del diseñador se queda.
-- ---------------------------------------------------------------------------
UPDATE psjy_leoslideshow_slides_lang
   SET layersparams = ''
 WHERE layersparams <> '';


-- ---------------------------------------------------------------------------
-- PASO 3 — VERIFICACION. Las dos primeras deben dar 0.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 3 verificacion ---' AS ``;
SELECT
  (SELECT COUNT(*) FROM psjy_leoslideshow_slides_lang
     WHERE layersparams <> '')                                  AS quedan_capas,
  (SELECT COUNT(*) FROM psjy_leoslideshow_slides_lang
     WHERE image IS NULL OR image = '')                         AS slides_sin_imagen,
  (SELECT COUNT(*) FROM psjy_leoslideshow_slides_lang)          AS filas_totales,
  (SELECT COUNT(*) FROM psjy_leoslideshow_slides_lang c
     JOIN psjy_leoslideshow_slides_lang_bk_20260811 b
       ON b.id_leoslideshow_slides = c.id_leoslideshow_slides
      AND b.id_lang = c.id_lang
    WHERE c.image <> b.image)                                   AS imagenes_cambiadas_por_error;

-- `slides_sin_imagen` es informativo: si sale > 0, esas diapositivas se
-- quedarian en el color de fondo del grupo (#d9d9d9). No lo causa este script.
-- `imagenes_cambiadas_por_error` TIENE que ser 0: confirma que no se toco
-- ninguna foto.

SELECT '--- PASO 3b: las imagenes de fondo siguen intactas ---' AS ``;
SELECT s.id_group AS grupo, s.id_leoslideshow_slides AS slide, s.active AS activa,
       sl.id_lang AS idioma, sl.image AS imagen_de_fondo,
       LENGTH(sl.layersparams) AS capas_bytes
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang sl
    ON sl.id_leoslideshow_slides = s.id_leoslideshow_slides
 ORDER BY s.id_group, s.position, sl.id_lang;


-- ---------------------------------------------------------------------------
-- PASO 4 — LO QUE FALTA, Y NO ES SQL
--
--   4.1  Vaciar cachés: back office -> Parametros avanzados -> Rendimiento ->
--        "Vaciar la cache". Sin esto la portada sigue sirviendo el HTML viejo
--        y parece que el script no hizo nada.
--
--   4.2  TAMAÑO DE LAS IMAGENES. El recorte en altura no lo causan las capas:
--        `iview.js:342` pinta la foto con `background-size: 100%`, o sea la
--        escala al ANCHO del contenedor y deja el alto libre — dentro de una
--        caja de alto FIJO que el propio JS pone en linea (`iview.js:23`) a
--        partir del alto configurado en el grupo.
--
--        Grupo 3 (escritorio): width 1920 · height 700  -> proporcion 2,743
--        Grupo 5 (movil):      width 460  · height 460  -> proporcion 1,000
--
--        La imagen que se subio (`web2.jpg`) es 1928 x 730 = proporcion 2,641.
--        A 1920 de ancho se pinta a 727 px de alto en una caja de 700: se
--        pierden 27 px por abajo.
--
--        Regla practica para el diseñador:
--          · Escritorio: subir EXACTAMENTE 1920 x 700 px (o cualquier tamaño
--            con esa misma proporcion: 2742x1000, 1371x500...).
--          · Movil: subir CUADRADA, 460 x 460 px.
--        Si sube mas alta, se corta por abajo. Si la sube mas baja, queda una
--        franja gris (#d9d9d9, el color de fondo del grupo).
--
--        Alternativa, si prefiere subir con otra forma: cambiar el alto del
--        grupo en Diseño -> Leo Slideshow -> editar el grupo -> Height, para
--        que cuadre con la proporcion que el vaya a usar siempre.
--
--   4.3  ⚠️ EN MOVIL AHORA MISMO NO HAY HERO. Medido pidiendo la portada de
--        produccion con user-agent de iPhone: 0 apariciones de `iview` y de
--        `leoslideshow`, o sea el modulo no pinta nada. El grupo 5 se quedo
--        sin diapositivas activas. Hay que crear al menos una, cuadrada.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- PASO 5 — MARCHA ATRAS (devuelve TODAS las capas tal y como estaban)
--
--   UPDATE psjy_leoslideshow_slides_lang c
--     JOIN psjy_leoslideshow_slides_lang_bk_20260811 b
--       ON b.id_leoslideshow_slides = c.id_leoslideshow_slides
--      AND b.id_lang = c.id_lang
--      SET c.layersparams = b.layersparams;
--
--   Y vaciar cachés otra vez.
-- ---------------------------------------------------------------------------
