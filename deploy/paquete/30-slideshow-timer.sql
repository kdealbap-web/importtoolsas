-- ===========================================================================
-- 30 — El hero: por que no gira ni sale el anillo, y como dejarlo funcionando
-- Importtools S.A.S · prefijo psjy_ · 12/08/2026
-- ---------------------------------------------------------------------------
-- EL SINTOMA QUE REPORTO EL CLIENTE
--   «el iview-timer, que estaba en rojo y tenia play y pause, para que
--    automaticamente se cambiaran los slides, se daño o dejo de funcionar».
--
-- LA CAUSA, MEDIDA — y no es nada que hayamos cambiado nosotros
--   `iview.js` no monta el anillo ni el autoavance cuando el grupo tiene UNA
--   SOLA diapositiva. Son tres guardas del propio modulo, sin tocar:
--     linea 127  if (iv.defs.total > 1 && iv.defs.timer != "bar")  -> crea el anillo
--     linea 199  if (iv.defs.total > 1 && …)                       -> lo dibuja
--     linea 492  if (iv.options.autoAdvance && iv.defs.total > 1)  -> lo arranca
--   Con `total == 1` el <div class="iview-timer"> se crea vacio y se queda a 0x0,
--   y ademas desaparecen los puntos (`iview-controlNav`) y las flechas
--   (`iview-directionNav`), porque cuelgan de la misma condicion.
--
--   Comprobado con una prueba A/B en el espejo, MISMO CODIGO en los dos lados:
--     · grupo con 1 diapositiva activa -> `.iview-timer` w=0 h=0, 0 <svg>, 0 <path>
--     · grupo con 2 diapositivas       -> `.iview-timer` 44x44, 1 <svg>, 3 <path>
--
--   Y en produccion, medido pidiendo la portada el 12/08: el widget del home sirve
--   el grupo 6 con UNA sola diapositiva (una sola aparicion de `data-leo_image`),
--   tanto con user-agent de escritorio como de iPhone.
--
-- LO QUE YA ESTA ARREGLADO POR CODIGO (no hace falta SQL)
--   · El anillo vuelve a ser ROJO de marca. Lo pinta Raphael con atributos de
--     presentacion SVG, y una regla CSS gana a un atributo de presentacion, asi
--     que se resuelve en `custom.css` §21 sin tocar el modulo ni los parametros:
--     el arco y el sector van a #E2211C y el aro de fondo se queda oscuro.
--     Verificado midiendo el estilo calculado: path 2 `stroke: rgb(226,33,28)`,
--     path 3 `fill: rgb(226,33,28)`.
--   · El play/pause ya lo trae el modulo (`iview.js:299`) y funciona en cuanto el
--     anillo existe. No estaba roto: no existia.
--   · El RECORTE de altura tambien se arregla por codigo (`custom.js` + §21): la
--     caja del hero pasa a seguir la proporcion real de la imagen, asi que ya no
--     depende de que el alto del grupo cuadre con la foto que suba el cliente.
--
-- LO QUE SOLO PUEDE ARREGLARSE CON DATOS
--   Que haya MAS DE UNA diapositiva activa en el grupo que usa el home. Ninguna
--   linea de CSS puede inventar una segunda imagen.
--
-- COMO SE USA
--   cPanel -> phpMyAdmin -> base de la tienda -> «SQL» -> pegar entero.
--   Los pasos 1 a 4 solo LEEN. El unico que escribe es el 5 y esta comentado a
--   proposito: hay que leer antes el resultado del paso 3.
-- ===========================================================================

SET NAMES utf8mb4;
SET SQL_MODE = '';


-- ---------------------------------------------------------------------------
-- PASO 1 — Que grupo usa REALMENTE el home, y cual el movil.
--   El widget guarda el `randkey` del grupo dentro del JSON de Leo Elements, con
--   una clave por dispositivo.
--   ⚠️ La de escritorio es `source__desktop`, NO `source`. La primera version de
--   esta consulta buscaba `"source":"…"` y devolvia 0 para el grupo de escritorio
--   —o sea que habria hecho creer que el hero de escritorio no lo pinta nadie—.
--   Se comprobo imprimiendo el JSON crudo:
--     "settings":{"source__desktop":"4df6…","source__tablet":"340a…","source__mobile":"340a…"}
--   ⚠️ NO vale mirar `LEOSLIDESHOW_GROUP_DE`: eso es el grupo que abre el menu
--   del back office, no el que se pinta. Confundirlos ya costo una ronda entera
--   el 08/08 y otra el 11/08.
--   ⚠️ Y NO vale traer el id del espejo: el 09/08 un script llevaba
--   `id_leoslideshow_slides = 6` sacado del espejo y en produccion habria borrado
--   del carrusel una diapositiva que funcionaba. Aqui se decide por datos.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 1: grupos referenciados por algun contenido ---' AS ``;
SELECT g.id_leoslideshow_groups                       AS grupo,
       g.title,
       g.active                                       AS grupo_activo,
       GROUP_CONCAT(DISTINCT c.id_leoelements_contents ORDER BY c.id_leoelements_contents) AS en_contenidos,
       SUM(c.content LIKE CONCAT('%"source__desktop":"', g.randkey, '"%')) AS como_escritorio,
       SUM(c.content LIKE CONCAT('%"source__mobile":"', g.randkey, '"%'))  AS como_movil,
       SUM(c.content LIKE CONCAT('%"source__tablet":"', g.randkey, '"%'))  AS como_tablet
  FROM psjy_leoslideshow_groups g
  JOIN psjy_leoelements_contents_lang c
    ON c.content LIKE CONCAT('%', g.randkey, '%')
 WHERE c.id_lang = 1
 GROUP BY g.id_leoslideshow_groups, g.title, g.active
 ORDER BY grupo;
-- Si un grupo NO sale en esta lista, no se pinta en ninguna pagina: cambiarlo no
-- se ve. Es exactamente lo que le pasaba al cliente el 08 y el 11 de agosto.


-- ---------------------------------------------------------------------------
-- PASO 2 — Cuantas diapositivas ACTIVAS tiene cada grupo. Es LA cifra del caso.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 2: diapositivas por grupo ---' AS ``;
SELECT g.id_leoslideshow_groups                    AS grupo,
       g.title,
       COUNT(s.id_leoslideshow_slides)             AS total,
       SUM(s.active = 1)                           AS activas,
       CASE WHEN SUM(s.active = 1) > 1
            THEN 'OK: gira y sale el anillo'
            ELSE 'SIN ANILLO NI AUTOAVANCE (hace falta mas de 1 activa)'
       END                                         AS diagnostico
  FROM psjy_leoslideshow_groups g
  LEFT JOIN psjy_leoslideshow_slides s
    ON s.id_group = g.id_leoslideshow_groups
 GROUP BY g.id_leoslideshow_groups, g.title
 ORDER BY grupo;


-- ---------------------------------------------------------------------------
-- PASO 3 — Diapositiva por diapositiva: si hay alguna DESACTIVADA con imagen,
--          activarla es todo lo que falta. Si no hay ninguna, el cliente tiene
--          que subir una segunda foto desde el panel.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 3: detalle de cada diapositiva ---' AS ``;
SELECT s.id_group                        AS grupo,
       s.id_leoslideshow_slides          AS slide,
       s.position                        AS pos,
       s.active                          AS activa,
       sl.id_lang                        AS lang,
       sl.title,
       sl.image                          AS imagen,
       CASE WHEN sl.image IS NULL OR sl.image = '' THEN 'SIN IMAGEN'
            WHEN s.active = 0 THEN 'desactivada — se puede activar (ver paso 5)'
            ELSE 'en uso' END            AS estado
  FROM psjy_leoslideshow_slides s
  JOIN psjy_leoslideshow_slides_lang sl
    ON sl.id_leoslideshow_slides = s.id_leoslideshow_slides
 ORDER BY s.id_group, s.position, s.id_leoslideshow_slides, sl.id_lang;


-- ---------------------------------------------------------------------------
-- PASO 4 — El grupo que abre el menu del back office. Si apunta a un grupo que
--          el PASO 1 no lista como usado, el cliente edita a ciegas: guarda bien
--          y no ve el cambio. Ha pasado dos veces.
-- ---------------------------------------------------------------------------
SELECT '--- PASO 4: LEOSLIDESHOW_GROUP_DE ---' AS ``;
SELECT value AS grupo_que_abre_el_menu FROM psjy_configuration
 WHERE name = 'LEOSLIDESHOW_GROUP_DE';


-- ---------------------------------------------------------------------------
-- PASO 5 — EL UNICO PASO QUE ESCRIBE. Descomentar SOLO si el paso 3 muestra una
--          diapositiva desactivada CON imagen en el grupo que usa el home.
--
--          Se pone el id a mano, leido del paso 3 de ESTA base. No se deja un
--          UPDATE «automatico» a proposito: activar a ciegas podria reactivar una
--          diapositiva que el cliente apago queriendo, y el 09/08 ya hubo un
--          script que iba a borrar una diapositiva buena por llevar un id del
--          espejo.
--
--   UPDATE psjy_leoslideshow_slides SET active = 1
--    WHERE id_leoslideshow_slides = <<< EL ID DEL PASO 3 >>>;
--
--          Y despues, para comprobar que ya son mas de una:
--   SELECT id_group, SUM(active = 1) AS activas
--     FROM psjy_leoslideshow_slides GROUP BY id_group;
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- PASO 6 — QUE DECIRLE AL CLIENTE (no es SQL, pero es la mitad del arreglo)
--
--   6.1  El carrusel del home necesita AL MENOS DOS imagenes. Con una sola, el
--        propio modulo apaga el anillo rojo, el play/pause, los puntos y las
--        flechas: no hay nada entre lo que pasar. Se añaden en
--        Diseño -> Leo Slideshow Configuration -> el grupo que use el home ->
--        «Add new slide».
--
--   6.2  Ya NO hace falta que la imagen tenga una medida exacta. Antes, si la
--        proporcion no coincidia con la del grupo, se recortaba por abajo o
--        quedaba una banda; ahora la caja del hero se adapta a la foto. Aun asi,
--        lo mas limpio sigue siendo que TODAS las del mismo grupo tengan la misma
--        proporcion, porque el grupo tiene un solo alto para todas.
--
--   6.3  Conviene que el grupo de MOVIL tenga sus propias imagenes, mas
--        cuadradas. En produccion hoy el movil sirve el mismo grupo apaisado que
--        el escritorio (medido pidiendo la portada con user-agent de iPhone), y
--        una foto de 2076x758 en la pantalla de un telefono se queda en una tira
--        muy baja. No es un fallo: es que la foto es asi de ancha.
--
--   6.4  Al guardar en Leo Slideshow se vacia la cache, y la PRIMERA visita
--        despues reconstruye la portada. Es normal que esa tarde unos segundos.
-- ---------------------------------------------------------------------------
