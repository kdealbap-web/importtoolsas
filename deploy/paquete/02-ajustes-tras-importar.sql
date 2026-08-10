-- ============================================================================
--  Importtools S.A.S — ajustes OBLIGATORIOS despues de importar el volcado
--  importtools-*.sql en el servidor de produccion.
--  Ejecutar en phpMyAdmin sobre la base de datos de la tienda.
--  Prefijo de tablas: psjy_
-- ============================================================================

-- 0) MANTENIMIENTO. Lo primero, porque el volcado trae PS_SHOP_ENABLE = 1 del
--    espejo: al importar, la tienda queda ABIERTA al publico en mitad del
--    despliegue, con los ficheros a medio subir. Se vuelve a cerrar aqui y se
--    abre a mano al final, cuando todo este comprobado.
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SHOP_ENABLE';

--    NO hace falta poner tu IP: PS_MAINTENANCE_ALLOW_ADMINS esta en 1, asi que
--    mientras tengas sesion abierta en el back office sigues viendo la tienda
--    normal y los visitantes ven el aviso.
--    ⚠️ Y la fila PS_MAINTENANCE_IP NO EXISTE en esta base (comprobado: 0 filas),
--    de modo que un UPDATE sobre ella no haria nada y no avisaria. Si aun asi
--    quieres permitir una IP concreta, hay que INSERTARLA, no actualizarla:
--
--        INSERT INTO psjy_configuration (name, value, date_add, date_upd)
--        VALUES ('PS_MAINTENANCE_IP', 'TU.IP.PUBLICA', NOW(), NOW())
--        ON DUPLICATE KEY UPDATE value = VALUES(value), date_upd = NOW();

-- 1) Dominio de la tienda. El volcado viene del entorno local (localhost:8080).
--    Sustituye www.importtoolsas.com si el dominio definitivo fuera otro.
UPDATE psjy_shop_url
   SET domain     = 'www.importtoolsas.com',
       domain_ssl = 'www.importtoolsas.com',
       physical_uri = '/',
       virtual_uri  = ''
 WHERE id_shop = 1;

UPDATE psjy_configuration SET value = 'www.importtoolsas.com' WHERE name = 'PS_SHOP_DOMAIN';
UPDATE psjy_configuration SET value = 'www.importtoolsas.com' WHERE name = 'PS_SHOP_DOMAIN_SSL';

-- 2) HTTPS. En local estaba desactivado; en produccion hay certificado.
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SSL_ENABLED';
--    Aqui habia tambien un UPDATE de PS_SSL_ENABLED_EVERYWHERE. Se retiro: esa
--    opcion NO existe en PrestaShop 9 — ni la fila en la base (0 filas) ni la
--    constante en el nucleo (0 apariciones en classes/, config/ y src/). El
--    UPDATE no hacia nada y no avisaba, que es lo peligroso de esta clase de
--    linea: parece que configura algo y no configura nada.

-- 3) Vaciar la cache de CSS de Elementor. IMPRESCINDIBLE: si no se hace, el sitio
--    sirve el CSS generado en local (con rutas y colores antiguos).
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';

-- 4) Modo catalogo. Es la decision definitiva: catalogo sin precios, sin carrito
--    y sin pasarela; se cotiza por WhatsApp. Viene ya asi en el volcado, pero se
--    reafirma aqui por si el volcado se importa sobre una base con otros valores.
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE';
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_CATALOG_MODE_WITH_PRICES';

-- ============================================================================
--  COMPROBACIONES (deben devolver lo indicado)
-- ============================================================================

--  a) 3036 productos, todos en la categoria raiz Catalogo; 7 marcas; 6072 caracteristicas
SELECT (SELECT COUNT(*) FROM psjy_product)                              AS productos,
       (SELECT COUNT(*) FROM psjy_category_product WHERE id_category=2) AS en_catalogo,
       (SELECT COUNT(*) FROM psjy_manufacturer)                         AS marcas,
       (SELECT COUNT(*) FROM psjy_feature_product)                      AS caracteristicas;

--  b) el idioma debe ser es-CO con iso 'es'
SELECT id_lang, iso_code, locale, active FROM psjy_lang;

--  c) el menu principal
SELECT m.position, l.title FROM psjy_btmegamenu m
  JOIN psjy_btmegamenu_lang l ON l.id_btmegamenu = m.id_btmegamenu AND l.id_lang = 2
 WHERE m.id_group = 1 AND m.id_parent = 0 AND m.active = 1 ORDER BY m.position;

--  d) modulo de cotizacion instalado y su tabla vacia (0 prospectos de prueba)
SELECT (SELECT active FROM psjy_module WHERE name = 'itcotizacion')  AS modulo_activo,
       (SELECT COUNT(*) FROM psjy_it_cotizacion)                     AS prospectos,
       (SELECT value FROM psjy_configuration WHERE name='ITCOT_WHATSAPP') AS whatsapp;

--  e) las dos paginas rehechas deben traer el marcado nuevo (no texto plano)
SELECT id_cms,
       CHAR_LENGTH(content)                     AS caracteres,
       content LIKE '%itqs-hero%'               AS trae_diseno_nuevo
  FROM psjy_cms_lang
 WHERE id_cms IN (4, 7) AND id_lang = 1;

--  f) la tienda debe quedar CERRADA (PS_SHOP_ENABLE = 0) y en modo catalogo.
--     PS_MAINTENANCE_ALLOW_ADMINS = 1 es lo que te deja verla a ti.
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_SHOP_ENABLE', 'PS_MAINTENANCE_ALLOW_ADMINS',
                'PS_CATALOG_MODE', 'PS_CATALOG_MODE_WITH_PRICES');

-- ============================================================================
--  AL TERMINAR, y solo cuando la tienda este comprobada, abrirla:
--     UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SHOP_ENABLE';
-- ============================================================================
