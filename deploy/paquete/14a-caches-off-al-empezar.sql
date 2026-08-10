-- ============================================================================
--  Importtools S.A.S — PASO 1 del despliegue: apagar las cachés de Smarty
--  Ejecutar en phpMyAdmin sobre la base de la tienda, ANTES de subir ficheros.
--  Prefijo de tablas: psjy_
-- ============================================================================
--
--  ⚠️ ESTE ES EL PASO QUE MÁS TIEMPO COSTÓ DESCUBRIR (despliegue del 31/07/2026).
--
--  `config/smarty.config.inc.php:22` hace:
--      if (!Configuration::get('PS_SMARTY_FORCE_COMPILE'))
--          $smarty->compile_check = COMPILECHECK_OFF;
--
--  Con `compile_check` apagado, Smarty **ni mira** si la plantilla cambió: sirve
--  lo que compiló la instalación anterior. Se puede subir el tema entero, las
--  traducciones y los widgets sin que cambie un solo píxel en la tienda, y sin
--  ningún mensaje de error. Pasó: dos rondas diagnosticando el sitio equivocado.
--
--  Mientras esto esté a 1 la tienda va MÁS LENTA (recompila en cada visita). Es
--  a propósito, y solo dura el despliegue: al terminar se ejecuta
--  `14b-caches-on-al-terminar.sql`.
-- ============================================================================

UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SMARTY_FORCE_COMPILE';
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SMARTY_CACHE';

-- Y cerrar la tienda al público mientras se trabaja.
--   PS_MAINTENANCE_ALLOW_ADMINS = 1 es lo que te deja seguir viéndola a ti con
--   la sesión del back office abierta. No hace falta añadir tu IP.
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SHOP_ENABLE';

-- ---------------------------------------------------------------------------
--  COMPROBACIÓN — tiene que devolver exactamente esto:
--      PS_SHOP_ENABLE               0
--      PS_SMARTY_CACHE              0
--      PS_SMARTY_FORCE_COMPILE      1
--      PS_MAINTENANCE_ALLOW_ADMINS  1
-- ---------------------------------------------------------------------------
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_SHOP_ENABLE', 'PS_SMARTY_CACHE',
                'PS_SMARTY_FORCE_COMPILE', 'PS_MAINTENANCE_ALLOW_ADMINS')
 ORDER BY name;
