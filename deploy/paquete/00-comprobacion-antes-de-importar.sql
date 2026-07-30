-- ============================================================================
--  FASE 0 — comprobacion previa. Ejecutar en phpMyAdmin, SOBRE PRODUCCION.
--
--  Todo es de SOLO LECTURA: no cambia nada. Devuelve una fila con lo que hay
--  que confirmar antes de importar el volcado, que sobrescribe la base entera.
-- ============================================================================

SELECT
  -- ¿Estoy en la base correcta? ~19 = produccion · 3036 = el entorno espejo
  (SELECT COUNT(*)      FROM psjy_product)   AS productos,
  (SELECT MAX(date_upd) FROM psjy_product)   AS ultimo_producto,
  -- ¿Hay actividad real posterior al 24/07/2026?
  (SELECT COUNT(*)      FROM psjy_orders)    AS pedidos,
  (SELECT MAX(date_add) FROM psjy_orders)    AS ultimo_pedido,
  (SELECT COUNT(*)      FROM psjy_customer)  AS clientes,
  (SELECT MAX(date_add) FROM psjy_customer)  AS ultimo_cliente,
  (SELECT COUNT(*)      FROM psjy_cms)       AS paginas_cms,
  (SELECT COUNT(*)      FROM psjy_employee)  AS empleados;

-- Version, dominio y estado del mantenimiento
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_VERSION_DB','PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL','PS_SSL_ENABLED',
                'PS_SHOP_ENABLE','PS_MAINTENANCE_IP','PS_LANG_DEFAULT')
 ORDER BY name;

-- Idiomas instalados (confirmar que el iso_code no es 'cb')
SELECT id_lang, iso_code, locale, active FROM psjy_lang;

-- Prefijo real de las tablas: deben salir 300+ y todas 'psjy_'
SELECT COUNT(*) AS tablas_psjy FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE 'psjy\_%';
SELECT COUNT(*) AS tablas_con_otro_prefijo FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME NOT LIKE 'psjy\_%';


-- ============================================================================
--  COMO LEER EL RESULTADO
-- ============================================================================
--
--  productos ~19          -> es produccion. Adelante.
--  productos 3036         -> ¡PARA! estas en el espejo, no en produccion.
--
--  Las tres fechas en 2026-07-24 11:07:54 -> son los datos de ejemplo de la
--  instalacion, creados de golpe. No ha habido ventas ni cambios reales.
--  Cualquier fecha POSTERIOR -> hay actividad real: NO importes el volcado
--  completo, habria que hacer una importacion selectiva por tablas.
--
--  PS_VERSION_DB debe ser 9.1.4. Si no, avisame antes de seguir.
--  tablas_con_otro_prefijo debe ser 0.
-- ============================================================================


-- ============================================================================
--  OPCIONAL, y solo tiene sentido AHORA: el texto de la pagina de mantenimiento
--
--  En produccion ese texto sigue en INGLES («We are currently updating our shop
--  and will be back really soon»). La correccion viaja dentro del volcado, o sea
--  que llega DESPUES de que actives el mantenimiento en el paso 0.4.
--
--  Si quieres que quien entre durante la importacion lo lea en español, ejecuta
--  esto ANTES del paso 0.4. Si te da igual (son ~60 minutos y el trafico es
--  bajo), saltatelo: el volcado lo deja bien de todas formas.
-- ============================================================================
--
-- UPDATE psjy_configuration_lang cl
--    JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
--     SET cl.value = 'Estamos actualizando la tienda y volvemos en unos minutos.\nGracias por tu paciencia.'
--   WHERE c.name = 'PS_MAINTENANCE_TEXT';
