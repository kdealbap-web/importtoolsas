-- ===========================================================================
-- 22 — La primera diapositiva del hero seguía siendo la de la demo · 08/08/2026
-- ---------------------------------------------------------------------------
-- HALLAZGO
--
-- La diapositiva 1 del carrusel de la portada (grupo 3, el que se ve en
-- escritorio) apuntaba a `sample_slider_1.png`: la imagen de MUESTRA que trae el
-- tema AutoSoe. Es una foto de archivo de **un lago con montañas y un muelle de
-- madera** — nada que ver con una ferretería en Galapa.
--
-- Se veía de verdad: el carrusel alterna cada 5 s, así que uno de cada dos
-- visitantes aterrizaba en una foto de un lago con el titular «TORNILLERÍA Y
-- HERRAMIENTA MANUAL» encima.
--
-- Y ya estaba preparada la imagen correcta: `/img/it/slide-1.jpg`, el degradado
-- azul de marca, hermano del `/img/it/slide-2.jpg` que sí usa la diapositiva 2.
-- Simplemente nunca se llegó a asignar.
--
-- Prefijo real: psjy_
-- ===========================================================================

SELECT '--- ANTES ---' AS ``;
SELECT s.id_leoslideshow_slides AS slide, l.id_lang, l.title, l.image
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang l ON l.id_leoslideshow_slides = s.id_leoslideshow_slides
 WHERE s.id_group = 3
 ORDER BY s.id_leoslideshow_slides, l.id_lang;

-- Se cambia SOLO donde está la imagen de muestra, en todos los idiomas.
UPDATE psjy_leoslideshow_slides_lang
   SET image = '/img/it/slide-1.jpg'
 WHERE image = 'sample_slider_1.png';

-- Por si alguna otra diapositiva heredó las otras dos muestras del tema.
UPDATE psjy_leoslideshow_slides_lang
   SET image = '/img/it/slide-2.jpg'
 WHERE image IN ('sample_slider_2.jpg', 'sample_slider_3.png');

SELECT '--- DESPUES (no debe quedar ningun sample_slider) ---' AS ``;
SELECT s.id_leoslideshow_slides AS slide, l.id_lang, l.title, l.image
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang l ON l.id_leoslideshow_slides = s.id_leoslideshow_slides
 ORDER BY s.id_leoslideshow_slides, l.id_lang;


-- ---------------------------------------------------------------------------
-- 22-bis  La PRIMERA diapositiva de la portada estaba VACÍA
-- ---------------------------------------------------------------------------
-- Auditadas las 11 diapositivas contando sus capas de texto:
--
--   grupo 3 (portada escritorio)  slide 6  -> 0 capas   <-- vacía
--   grupo 3 (portada escritorio)  slide 7  -> 5 capas
--   grupo 5 (portada móvil)       slides 10 y 11 -> 3 capas cada una
--   el resto de grupos no se usan en ninguna página
--
-- La 6 es la ÚNICA sin capas, y es **la primera que ve el visitante** en
-- escritorio. Sin capas no hay titular, ni texto, ni botón: solo el fondo. Es
-- decir, uno de cada dos visitantes aterrizaba en una banda oscura vacía y
-- esperaba 9 segundos a que entrara la diapositiva 2, que sí tiene mensaje.
--
-- (Antes ese fondo era además la foto del lago de la demo, ver arriba. Las dos
-- cosas juntas explican las bandas «en blanco» que aparecían en las capturas.)
--
-- Se DESACTIVA, que es lo reversible y honesto: no inventamos un mensaje que el
-- cliente no ha escrito. El carrusel se queda con la diapositiva que sí
-- comunica, y el cliente puede diseñar la primera cuando quiera desde
--   Diseño → Leo Slideshow Configuration → «Slide Home 3» → Slide 1
-- y activarla ahí mismo. El módulo de banners ya funciona (ver 18 §6).
--
-- ⚠️ CORREGIDO EL 09/08/2026 — ESTO ERA PELIGROSO EN PRODUCCIÓN.
--    Antes decía `WHERE id_leoslideshow_slides = 6`, un id copiado del espejo.
--    Comprobado contra la tienda real ese mismo día: **en producción la
--    diapositiva 6 NO está vacía** — lleva 7 capas y el titular «Herramienta
--    profesional para tu taller», y es la primera de la portada. Ejecutar el
--    UPDATE con el id a mano habría BORRADO del carrusel una diapositiva que
--    funciona. El espejo y producción habían divergido en esta tabla.
--
--    Ahora la condición es POR DATOS: desactiva la diapositiva que esté vacía,
--    sea cual sea su id, y no toca ninguna que tenga capas. En producción, hoy,
--    afecta a 0 filas — que es justo lo correcto.
--
--    Probado de ida y vuelta en el espejo: se reactivó la 6, se ejecutó, volvió
--    a quedar en 0 (1 fila) y las diapositivas 7, 10 y 11 no se tocaron.
--
--    (Si `layersparams` no fuera base64 válido, `FROM_BASE64()` devuelve NULL y
--    la comparación no casa: el fallo cae del lado seguro, no desactiva nada.)
--
-- ⚠️ SEGUNDA CORRECCIÓN, 10/08/2026 — AHORA SOLO INFORMA, NO DESACTIVA.
--    El cliente ya gestiona los banners desde el panel (el módulo se arregló). Una
--    diapositiva **recién creada y todavía sin capas** es indistinguible de la
--    diapositiva vacía de la demo: el UPDATE de arriba se la habría desactivado
--    por la espalda, y el cliente habría visto desaparecer su banner a medio
--    hacer sin saber por qué.
--    En producción hoy hay **0 candidatas**, así que no se pierde nada informando.
--    Si algún día sale alguna, se decide mirándola, no a ciegas.

SELECT '--- diapositivas ACTIVAS y SIN CAPAS (candidatas, NO se tocan) ---' AS ``;
SELECT s.id_leoslideshow_slides AS slide, s.id_group AS grupo, l.title, l.image
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang l
    ON l.id_leoslideshow_slides = s.id_leoslideshow_slides AND l.id_lang = 2
 WHERE s.id_group IN (3, 5)
   AND s.active = 1
   AND (l.layersparams IS NULL OR l.layersparams = '' OR FROM_BASE64(l.layersparams) IN ('[]', 'null'));

-- Si la lista de arriba sale VACÍA (es el caso de producción), no hay nada que hacer.
-- Si sale alguna, míralas en el panel antes de decidir. Cuando estés seguro de que es
-- la heredada de la demo y no un banner que el cliente está montando, descomenta:
--
-- UPDATE psjy_leoslideshow_slides s
--   JOIN psjy_leoslideshow_slides_lang l
--     ON l.id_leoslideshow_slides = s.id_leoslideshow_slides AND l.id_lang = 2
--    SET s.active = 0
--  WHERE s.id_group IN (3, 5)
--    AND s.active = 1
--    AND (l.layersparams IS NULL OR l.layersparams = '' OR FROM_BASE64(l.layersparams) IN ('[]', 'null'));

SELECT '--- diapositivas de la portada, con sus capas ---' AS ``;
SELECT s.id_leoslideshow_slides AS slide, s.id_group AS grupo, s.active AS activa,
       l.title, l.image
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang l
    ON l.id_leoslideshow_slides = s.id_leoslideshow_slides AND l.id_lang = 2
 WHERE s.id_group IN (3, 5)
 ORDER BY s.id_group, s.position;

SELECT '--- comprobacion final ---' AS ``;
SELECT CONCAT('diapositivas que aun usan una imagen de muestra: ', COUNT(*)) AS resultado
  FROM psjy_leoslideshow_slides_lang WHERE image LIKE 'sample_slider%';
SELECT CONCAT('diapositivas ACTIVAS y VACIAS en la portada: ', COUNT(*)) AS resultado
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang l
    ON l.id_leoslideshow_slides = s.id_leoslideshow_slides AND l.id_lang = 2
 WHERE s.id_group IN (3, 5) AND s.active = 1
   AND (l.layersparams IS NULL OR l.layersparams = '' OR FROM_BASE64(l.layersparams) IN ('[]', 'null'));

-- Marcha atrás:
--   UPDATE psjy_leoslideshow_slides_lang SET image='sample_slider_1.png'
--    WHERE image='/img/it/slide-1.jpg';
--   UPDATE psjy_leoslideshow_slides SET active=1 WHERE id_group IN (3,5);
--
-- ⚠️ NOTA SOBRE PRODUCCIÓN (comprobada el 09/08/2026 sobre la tienda en línea):
--    la portada YA sirve `/img/it/slide-1.jpg` y `/img/it/slide-2.jpg`, y las dos
--    diapositivas tienen texto. O sea que en producción **este fichero entero no
--    cambia nada**: los dos UPDATE de imagen afectan a 0 filas y el de arriba
--    también. Se ejecuta igualmente porque deja constancia impresa del estado y
--    porque es el que hay que usar si algún día se repuebla desde el volcado del
--    espejo, donde sí había una diapositiva vacía y la imagen de la demo.
--
-- Después: vaciar `var/cache/` y recargar la portada.
-- El cliente puede cambiar esta imagen desde el panel:
--   Diseño → Leo Slideshow Configuration → grupo «Slide Home 3» → diapositiva 1.
