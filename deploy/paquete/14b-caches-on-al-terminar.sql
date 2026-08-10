-- ============================================================================
--  Importtools S.A.S — PASO FINAL: devolver las cachés a valores de producción
--  Ejecutar SOLO cuando las comprobaciones del §7 del paso a paso hayan pasado.
--  Prefijo de tablas: psjy_
-- ============================================================================
--
--  Este script NO abre la tienda. Eso es un acto aparte, a conciencia:
--  `14c-abrir-la-tienda.sql`.
--
--  Los cuatro valores son los mismos con los que corre el espejo local, o sea
--  los que están probados. Los tres que faltan del panel de Rendimiento
--  (comprimir HTML, comprimir JS en línea, aplazar la carga de JS) NO se tocan:
--  no existen como fila en esta base, corren con el valor por defecto del núcleo
--  y no los he probado aquí. Activarlos a ciegas el día del despliegue es la
--  forma más rápida de romper algo que ya funciona.
-- ============================================================================

-- Smarty vuelve a cachear y deja de recompilar en cada visita
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SMARTY_FORCE_COMPILE';
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SMARTY_CACHE';

-- Caché inteligente de CSS y JS (es la que produce el fichero único
-- themes/vt_autosoe_child/assets/cache/theme-<hash>.css). Debe quedar activa:
-- es la configuración contra la que se probó toda la maquetación.
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CSS_THEME_CACHE';
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_JS_THEME_CACHE';

-- ---------------------------------------------------------------------------
--  COMPROBACIÓN — tiene que devolver:
--      PS_CSS_THEME_CACHE        1
--      PS_JS_THEME_CACHE         1
--      PS_SMARTY_CACHE           1
--      PS_SMARTY_FORCE_COMPILE   0
--      PS_SHOP_ENABLE            0   <- sigue cerrada, es correcto
-- ---------------------------------------------------------------------------
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_CSS_THEME_CACHE', 'PS_JS_THEME_CACHE',
                'PS_SMARTY_CACHE', 'PS_SMARTY_FORCE_COMPILE', 'PS_SHOP_ENABLE')
 ORDER BY name;

-- ⚠️ Después de esto hay que vaciar `var/cache/` UNA VEZ MÁS: al cambiar
--    PS_SMARTY_FORCE_COMPILE a 0, lo primero que se compile queda congelado.
